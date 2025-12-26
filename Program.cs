using System.IO.Compression;
using System.Security.Cryptography;
using System.Text;
using System.Xml.Linq;

string password;

if (args.Length == 0)
{
    Console.Write("Password: ");
    password = ReadPassword();
    Console.WriteLine();
}
else
{
    password = args[0];
}

string dbPath = "SafeInCloud.db";

if (!File.Exists(dbPath))
{
    Console.WriteLine($"Database file not found: {dbPath}");
    return 1;
}

try
{
    string xmlContent = DecryptSafeInCloud(dbPath, password);
    XDocument doc = XDocument.Parse(xmlContent);

    while (true)
    {
        Console.WriteLine("\nEnter search term (or press Enter to list all, CTRL+C to exit):");
        string? searchTerm = Console.ReadLine();

        var cards = doc.Descendants("card");
        var filteredCards = cards;

        if (!string.IsNullOrWhiteSpace(searchTerm))
        {
            filteredCards = cards.Where(c =>
                c.Attribute("title")?.Value.Contains(searchTerm, StringComparison.OrdinalIgnoreCase) == true);
        }

        var cardList = filteredCards.ToList();

        if (cardList.Count == 0)
        {
            Console.WriteLine("No entries found");
            continue;
        }

        for (int i = 0; i < cardList.Count; i++)
        {
            Console.WriteLine($"{i + 1}. {cardList[i].Attribute("title")?.Value}");
        }

        Console.WriteLine("\nEnter number to view details (or press Enter to search again):");
        string? input = Console.ReadLine();

        if (string.IsNullOrWhiteSpace(input))
            continue;

        if (int.TryParse(input, out int selection) && selection > 0 && selection <= cardList.Count)
        {
            var selectedCard = cardList[selection - 1];
            Console.WriteLine();

            if (selectedCard.Attribute("title") != null)
                Console.WriteLine($"title: {selectedCard.Attribute("title")?.Value}");

            foreach (var field in selectedCard.Descendants("field"))
            {
                string? fieldName = field.Attribute("name")?.Value;
                string? fieldValue = field.Value;

                if (!string.IsNullOrEmpty(fieldName))
                    Console.WriteLine($"{fieldName}: {fieldValue}");
            }

            var notes = selectedCard.Element("notes");
            if (notes != null && !string.IsNullOrWhiteSpace(notes.Value))
                Console.WriteLine($"notes: {notes.Value}");
        }
        else
        {
            Console.WriteLine("Invalid selection");
        }
    }
}
catch (Exception ex)
{
    Console.WriteLine($"Error: {ex.Message}");
    Console.WriteLine($"Stack: {ex.StackTrace}");
    return 1;
}

static string DecryptSafeInCloud(string dbPath, string password)
{
    using var fs = new FileStream(dbPath, FileMode.Open, FileAccess.Read);
    using var reader = new BinaryReader(fs);

    ushort magic = reader.ReadUInt16();
    byte version = reader.ReadByte();
    byte[] salt = ReadByteArray(reader);

    byte[] key1 = DeriveKey(Encoding.UTF8.GetBytes(password), salt, 10000);

    byte[] iv = ReadByteArray(reader);
    byte[] salt2 = ReadByteArray(reader);
    byte[] encryptedBlock = ReadByteArray(reader);

    byte[] decryptedBlock = DecryptAesCbc(encryptedBlock, key1, iv);

    using var blockStream = new MemoryStream(decryptedBlock);
    using var blockReader = new BinaryReader(blockStream);

    byte[] iv2 = ReadByteArray(blockReader);
    byte[] pass2 = ReadByteArray(blockReader);
    byte[] check = ReadByteArray(blockReader);

    byte[] key2 = DeriveKey(pass2, salt2, 1000);

    byte[] remainingData = reader.ReadBytes((int)(fs.Length - fs.Position));
    byte[] decryptedData = DecryptAesCbc(remainingData, pass2, iv2);

    byte[] decompressed = Decompress(decryptedData);

    int bomOffset = 0;
    if (decompressed.Length >= 3 &&
        decompressed[0] == 0xEF &&
        decompressed[1] == 0xBB &&
        decompressed[2] == 0xBF)
    {
        bomOffset = 3;
    }

    return Encoding.UTF8.GetString(decompressed, bomOffset, decompressed.Length - bomOffset);
}

static byte[] ReadByteArray(BinaryReader reader)
{
    byte size = reader.ReadByte();
    return reader.ReadBytes(size);
}

static byte[] DeriveKey(byte[] password, byte[] salt, int iterations)
{
    return Rfc2898DeriveBytes.Pbkdf2(password, salt, iterations, HashAlgorithmName.SHA1, 32);
}

static byte[] DecryptAesCbc(byte[] data, byte[] key, byte[] iv)
{
    using var aes = Aes.Create();
    aes.Key = key;
    aes.IV = iv;
    aes.Mode = CipherMode.CBC;
    aes.Padding = PaddingMode.None;

    using var decryptor = aes.CreateDecryptor();
    return decryptor.TransformFinalBlock(data, 0, data.Length);
}

static byte[] Decompress(byte[] data)
{
    int offset = 0;
    while (offset < data.Length && data[offset] == 0)
        offset++;

    if (offset >= data.Length)
        throw new InvalidDataException("No compressed data found");

    byte zlibHeader1 = data[offset];
    byte zlibHeader2 = data[offset + 1];

    if ((zlibHeader1 & 0x0F) == 0x08)
    {
        offset += 2;
    }

    using var compressedStream = new MemoryStream(data, offset, data.Length - offset - 4);
    using var deflateStream = new DeflateStream(compressedStream, CompressionMode.Decompress);
    using var resultStream = new MemoryStream();

    deflateStream.CopyTo(resultStream);
    return resultStream.ToArray();
}

static string ReadPassword()
{
    var password = new StringBuilder();
    while (true)
    {
        var key = Console.ReadKey(intercept: true);
        if (key.Key == ConsoleKey.Enter)
            break;
        if (key.Key == ConsoleKey.Backspace && password.Length > 0)
            password.Remove(password.Length - 1, 1);
        else if (!char.IsControl(key.KeyChar))
            password.Append(key.KeyChar);
    }
    return password.ToString();
}
