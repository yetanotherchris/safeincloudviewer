using System.IO.Compression;
using System.Security.Cryptography;
using System.Text;
using System.Xml.Linq;

if (args.Length == 0)
{
    Console.WriteLine("Usage: safecloud <password>");
    return 1;
}

string password = args[0];
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

    Console.WriteLine("Enter search term (or press Enter to list all):");
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
        return 0;
    }

    for (int i = 0; i < cardList.Count; i++)
    {
        Console.WriteLine($"{i + 1}. {cardList[i].Attribute("title")?.Value}");
    }

    Console.WriteLine("\nEnter number to view details:");
    if (int.TryParse(Console.ReadLine(), out int selection) && selection > 0 && selection <= cardList.Count)
    {
        var selectedCard = cardList[selection - 1];
        Console.WriteLine("\n--- Entry Details ---");
        Console.WriteLine(selectedCard.ToString());
    }

    return 0;
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

    return Encoding.UTF8.GetString(decompressed);
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

    using var compressedStream = new MemoryStream(data, offset, data.Length - offset);
    using var deflateStream = new DeflateStream(compressedStream, CompressionMode.Decompress);
    using var resultStream = new MemoryStream();

    deflateStream.CopyTo(resultStream);
    return resultStream.ToArray();
}
