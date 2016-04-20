using Microsoft.Azure.KeyVault;
using Microsoft.Azure.KeyVault.WebKey;
using Microsoft.IdentityModel.Clients.ActiveDirectory;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace AzureKeyVault101
{
    class Program
    {

        static ClientCredential clientCredential;

        static string vaultUrl = "https://jangelfdez-key-vault.vault.azure.net/";
        static string clientId = "ClientId";
        static string authClientSecret = "ClientSecret";

        static void Main(string[] args)
        {
            clientCredential = new ClientCredential(clientId, authClientSecret);

       
            KeyVaultClient keyVaultClient = new KeyVaultClient(new KeyVaultClient.AuthenticationCallback(GetAccessToken));

            // Obtaining the secret for our application
            Console.WriteLine("#################### Secrets");
            var results = keyVaultClient.GetSecretsAsync(vaultUrl).GetAwaiter().GetResult();
            results.Value.ToList().ForEach(i => {
                Console.WriteLine("Name: {0}, Identifier:{1}", i.Identifier.Name, i.Identifier.Identifier);
                var secret = keyVaultClient.GetSecretAsync(i.Id).GetAwaiter().GetResult();
                Console.WriteLine("-> Secret Value: {0} \n", secret.Value);
                });

            Console.ReadKey();

            // Encryption and decryption of information
            var keyId = "https://jangelfdez-key-vault.vault.azure.net:443/keys/softwareProtectedkey/901738e066144741944c274a192ad704";
            var text = "Hello World!";

            Console.WriteLine("#################### Encrypt ");
            var encryptedText = keyVaultClient.EncryptAsync(keyId, JsonWebKeyEncryptionAlgorithm.RSA15, Encoding.UTF8.GetBytes(text)).GetAwaiter().GetResult();
            Console.WriteLine("Text to encrypt: {0} , Encrypted (base64): {1} \n", text, Convert.ToBase64String(encryptedText.Result));

            Console.ReadKey();

            Console.WriteLine("#################### Decrypt");
            var decryptedText = keyVaultClient.DecryptAsync(keyId,JsonWebKeyEncryptionAlgorithm.RSA15, encryptedText.Result).GetAwaiter().GetResult();
            Console.WriteLine("Text to decrypt (base64): {0} , Decrypted: {1} \n", Convert.ToBase64String(encryptedText.Result), Encoding.UTF8.GetString(decryptedText.Result));

            Console.ReadKey();

        }

        public static async Task<string> GetAccessToken(string authority, string resource, string scope)
        {
            var context = new AuthenticationContext(authority, TokenCache.DefaultShared);
            var result = await context.AcquireTokenAsync(resource, clientCredential);

            return result.AccessToken;
        }
    }
}
