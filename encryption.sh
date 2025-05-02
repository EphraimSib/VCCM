# Generate a 32-byte (256-bit) encryption key
ENCRYPTION_KEY=$(openssl rand -hex 32)

# Generate a 16-byte (128-bit) IV
IV=$(openssl rand -hex 16)

# Encrypt a file
openssl enc -aes-256-cbc -salt -in input.txt -out encrypted.txt -K $ENCRYPTION_KEY -iv $IV

# Decrypt the file
openssl enc -aes-256-cbc -d -salt -in encrypted.txt -out decrypted.txt -K $ENCRYPTION_KEY -iv $IV
