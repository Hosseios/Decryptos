# Function to check if Python is installed
function Check-Python {
    $pythonExists = Get-Command python -ErrorAction SilentlyContinue
    return $pythonExists -ne $null
}

# Function to install Python packages using pip
function Install-Packages {
    Write-Host "$($global:Messages.InstallingPackages)"
    pip install pycryptodomex pypiwin32
}

# Function to update Python script with user-specific directory
function Update-PythonScript {
    param (
        [string]$username
    )

    $pythonScriptContent = @"
import os
import json
import base64
import sqlite3
import win32crypt
from Cryptodome.Cipher import AES
import shutil
import csv

BASE_PATH = r"C:\Users\$username\Desktop\PY"
LOCAL_STATE_PATH = os.path.join(BASE_PATH, "Local State")
LOGIN_DATA_PATH = os.path.join(BASE_PATH, "Login Data")

def get_secret_key():
    try:
        with open(LOCAL_STATE_PATH, "r", encoding='utf-8') as f:
            local_state = f.read()
            local_state = json.loads(local_state)
        secret_key = base64.b64decode(local_state["os_crypt"]["encrypted_key"])
        secret_key = secret_key[5:] 
        secret_key = win32crypt.CryptUnprotectData(secret_key, None, None, None, 0)[1]
        return secret_key
    except Exception as e:
        print("%s" % str(e))
        print("[ERR] Secret key cannot be found")
        return None
    
def decrypt_payload(cipher, payload):
    return cipher.decrypt(payload)

def generate_cipher(aes_key, iv):
    return AES.new(aes_key, AES.MODE_GCM, iv)

def decrypt_password(ciphertext, secret_key):
    try:
        initialisation_vector = ciphertext[3:15]
        encrypted_password = ciphertext[15:-16]
        cipher = generate_cipher(secret_key, initialisation_vector)
        decrypted_pass = decrypt_payload(cipher, encrypted_password)
        decrypted_pass = decrypted_pass.decode()  
        return decrypted_pass
    except Exception as e:
        print("%s" % str(e))
        print("[ERR] Unable to decrypt, Edge version <80 not supported. Please check.")
        return ""
    
def get_db_connection(file_path):
    try:
        print(file_path)
        shutil.copy2(file_path, "Loginvault.db") 
        return sqlite3.connect("Loginvault.db")
    except Exception as e:
        print("%s" % str(e))
        print("[ERR] Database cannot be found")
        return None
        
if __name__ == '__main__':
    try:
        with open('decrypted_password.csv', mode='w', newline='', encoding='utf-8') as decrypt_password_file:
            csv_writer = csv.writer(decrypt_password_file, delimiter=',')
            csv_writer.writerow(["index", "url", "username", "password"])
            secret_key = get_secret_key()
            conn = get_db_connection(LOGIN_DATA_PATH)
            if secret_key and conn:
                cursor = conn.cursor()
                cursor.execute("SELECT action_url, username_value, password_value FROM logins")
                for index, login in enumerate(cursor.fetchall()):
                    url = login[0]
                    username = login[1]
                    ciphertext = login[2]
                    if url != "" and username != "" and ciphertext != "":
                        decrypted_password = decrypt_password(ciphertext, secret_key)
                        print("Sequence: %d" % (index))
                        print("URL: %s\nUser Name: %s\nPassword: %s\n" % (url, username, decrypted_password))
                        print("*" * 50)
                        csv_writer.writerow([index, url, username, decrypted_password])
                cursor.close()
                conn.close()
                os.remove("Loginvault.db")
    except Exception as e:
        print("[ERR] %s" % str(e))
"@

    $desktopPath = [System.Environment]::GetFolderPath('Desktop')
    $outputFilePath = Join-Path $desktopPath "Generic.py"
    $pythonScriptContent | Out-File -FilePath $outputFilePath -Encoding utf8
}

# Function to execute the Python script
function Execute-PythonScript {
    param (
        [string]$scriptPath
    )

    Write-Host "$($global:Messages.ExecutingScript)"
    Start-Process python -ArgumentList $scriptPath -NoNewWindow -Wait
    Write-Host "$($global:Messages.ScriptExecuted)"
}

# Function to delete the Python script file
function Remove-PythonScript {
    param (
        [string]$scriptPath
    )

    if (Test-Path $scriptPath) {
        Remove-Item -Path $scriptPath -Force
    }
}

# Function to set messages based on language choice
function Set-Messages {
    param (
        [string]$language
    )
    
    if ($language -eq "EN") {
        $global:Messages = @{
            InstallingPackages   = "Installing required Python packages..."
            InstallPython        = "Please install Python by typing 'python' in the terminal that appears and following the instructions."
            EnterToContinue       = "Press Enter after you have installed Python..."
            PythonNotInstalled    = "Python is still not installed. Please install Python and rerun this script."
            CreateFolder          = "Please create a folder named 'PY' on your desktop."
            AddFiles              = "Add the required files ('Local State' and 'Login Data') to the 'PY' folder and press Enter to proceed."
            FilesPresent          = "Both 'Local State' and 'Login Data' files are present."
            PathNotExist          = "The path does not exist. Please ensure the folder is correctly named and located on your desktop."
            PathCorrect           = "The path is correctly set."
            DecryptingPasswords   = "The passwords have been decrypted and a .csv file has been saved to your desktop."
            ExecutingScript       = "Executing Python script..."
            ScriptExecuted        = "Python script executed."
            DeletingScript        = "Deleting the Python script file..."
            ScriptDeleted         = "Python script file deleted."
        }
    } elseif ($language -eq "PT") {
        $global:Messages = @{
            InstallingPackages   = "Instalando pacotes Python necessarios..."
            InstallPython        = "Por favor, instale o Python digitando 'python' no terminal que aparece e seguindo as instrucoes."
            EnterToContinue       = "Pressione Enter apos ter instalado o Python..."
            PythonNotInstalled    = "O Python ainda nao esta instalado. Por favor, instale o Python e execute este script novamente."
            CreateFolder          = "Por favor, crie uma pasta chamada 'PY' na sua area de trabalho."
            AddFiles              = "Adicione os arquivos necessarios ('Local State' e 'Login Data') a pasta 'PY' e pressione Enter para continuar."
            FilesPresent          = "Os arquivos 'Local State' e 'Login Data' estao presentes."
            PathNotExist          = "O caminho nao existe. Por favor, certifique-se de que a pasta esta nomeada corretamente e localizada na sua area de trabalho."
            PathCorrect           = "O caminho esta configurado corretamente."
            DecryptingPasswords   = "As senhas foram descriptografadas e um arquivo .csv foi salvo na sua area de trabalho."
            ExecutingScript       = "Executando o script Python..."
            ScriptExecuted        = "Script Python executado."
            DeletingScript        = "Excluindo o arquivo do script Python..."
            ScriptDeleted         = "Arquivo do script Python excluido."
        }
    } else {
        Write-Host "Invalid language selection. Exiting script."
        exit
    }
}

# Step 1: Language selection
Write-Host "Choose a language / Escolha um idioma:"
Write-Host "1. English"
Write-Host "2. Portugues"

$languageChoice = Read-Host "Enter 1 for English or 2 for Portuguese"

if ($languageChoice -eq "1") {
    Set-Messages -language "EN"
} elseif ($languageChoice -eq "2") {
    Set-Messages -language "PT"
} else {
    Write-Host "Invalid selection. Exiting script."
    exit
}

# Step 2: Check if Python is installed
if (-not (Check-Python)) {
    Write-Host "$($global:Messages.InstallPython)"
    Start-Process "cmd.exe" -ArgumentList "/c python" -NoNewWindow -Wait
    Read-Host "$($global:Messages.EnterToContinue)"

    # Step 3: Check again for Python installation
    if (-not (Check-Python)) {
        Write-Host "$($global:Messages.PythonNotInstalled)"
        exit
    }
}

Write-Host "Python is installed."

# Step 4: Install Python packages
Install-Packages

# Step 5: Check if the PY directory exists on the desktop
$desktopPath = [System.Environment]::GetFolderPath('Desktop')
$pyDirectory = Join-Path $desktopPath "PY"

if (-not (Test-Path $pyDirectory)) {
    Write-Host "$($global:Messages.CreateFolder)"
    Read-Host "Press Enter when done..."
}

# Step 6: Check if the required files are in the PY directory
$localStateFile = Join-Path $pyDirectory "Local State"
$loginDataFile = Join-Path $pyDirectory "Login Data"

# Check for the presence of both files
$fileExists = (Test-Path $localStateFile) -and (Test-Path $loginDataFile)

if ($fileExists) {
    Write-Host "$($global:Messages.FilesPresent)"
} else {
    Write-Host "$($global:Messages.AddFiles)"
    Read-Host "Press Enter when done..."
    # Re-check for the required files
    $fileExists = (Test-Path $localStateFile) -and (Test-Path $loginDataFile)
    if (-not $fileExists) {
        Write-Host "$($global:Messages.PathNotExist)"
        exit
    }
}

Write-Host "$($global:Messages.PathCorrect)"

# Step 7: Update and save the Python script
$userName = [System.Environment]::UserName
$baseDirectory = "C:\Users\$userName\Desktop\PY"

if (-not (Test-Path $baseDirectory)) {
    Write-Host "$($global:Messages.PathNotExist)"
    exit
}

Write-Host "$($global:Messages.PathCorrect)"

Update-PythonScript -username $userName

# Step 8: Execute the Python script
$pythonScriptPath = Join-Path $desktopPath "Generic.py"
Execute-PythonScript -scriptPath $pythonScriptPath

# Final message
Write-Host "$($global:Messages.DecryptingPasswords)"
