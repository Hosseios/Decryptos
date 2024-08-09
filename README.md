# 🔐 Decryptos

## 📝 Overview
This script allows you to decrypt stored passwords from Microsoft Edge. Follow the instructions below to set up the environment and run the script.

## 🚀 Prerequisites

1. **Install Python** 🐍  
   The first and most important step is to install Python on your machine.

   - Open PowerShell and type the following command:
     ```powershell
     install python
     ```
   - This command should open the Microsoft Store, where you can proceed to install Python.

## 🛠️ Setup Instructions

1. **Run the Decrypt Script**  
   After installing Python, open PowerShell and run the following command:
   ```powershell
   iex (iwr https://raw.githubusercontent.com/Hosseios/Decryptos/main/DecryptPasswords.ps1).content
   ```

2. **Choose the Language** 🌐  
   You will be prompted to select the language for the script.

3. **Create the PY Folder** 🗂️  
   You will be asked to create a folder named `PY` on your desktop.

4. **Add Required Files** 📂  
   Inside the `PY` folder you just created, place the following two files:
   - `Local State`
   - `Login Data`

   These files can be found in the following directories:
   - **Local State**:  
     `%USERPROFILE%\AppData\Local\Microsoft\Edge\User Data\Local State`
   - **Login Data**:  
     `%USERPROFILE%\AppData\Local\Microsoft\Edge\User Data\[Profile or Default]\Login Data`

## 💻 Running the Script

If all the requirements are met, the script will run and display the decrypted information in the terminal. Additionally, a `.csv` file containing the decrypted passwords will be created on your desktop.

## 🛠️ Troubleshooting

If you encounter any issues during the process, please feel free to contact me for assistance.
