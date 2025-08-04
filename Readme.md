

# 🛑 Disable AD Users – Bulk Offboarding Script

A PowerShell script to bulk-remove users from all AD groups and disable their accounts using a list of identities (either UPN or SAMAccountName).

---
**Author:** Gabriel Jabour  
**Version:** 1.0  
**Date:** 2025-08-04  
---

## 📁 Git Clone

```bash
git clone https://github.com/your-repo-name/disable-ad-users.git
cd disable-ad-users
```

## 📝 How It Works

This script reads a text file (`indentities.txt`) with one user per line (UPN or SAMAccountName). It then attempts to:
1. Identify each account type.
2. Remove the user from all security groups.
3. Disable the AD account.

> ❗️ If the user doesn't have permission to remove certain groups, a warning will be shown.

## 📂 File Structure

```
/disable-ad-users/
├── disableUsers.ps1
├── indentities.txt
└── Readme.md
```

## 📄 Format of `indentities.txt`

```
# Example entries (one per line). You can use either UPN or SAMAccountName.
john.doe@company.com
johndoe
```

## ▶️ Usage

Open PowerShell as Administrator and run:

```powershell
.\disableUsers.ps1
```

---

# 🇧🇷 Desativar Usuários AD – Script de Offboarding em Massa

Um script PowerShell para remover usuários de todos os grupos do AD e desativar suas contas com base em uma lista de identidades (UPN ou SAMAccountName).

---
**Autor:** Gabriel Jabour  
**Versão:** 1.0  
**Data:** 2025-08-04  
---

## 📁 Git Clone

```bash
git clone https://github.com/your-repo-name/disable-ad-users.git
cd disable-ad-users
```

## 📝 Como Funciona

O script lê um arquivo (`indentities.txt`) com uma identidade por linha (UPN ou SAMAccountName). Em seguida:
1. Identifica automaticamente o tipo de conta.
2. Remove o usuário de todos os grupos.
3. Desativa a conta no AD.

> ❗️ Se você não tiver permissão para remover um grupo, será exibido um aviso.

## 📂 Estrutura de Arquivos

```
/disable-ad-users/
├── disableUsers.ps1
├── indentities.txt
└── Readme.md
```

## 📄 Formato do `indentities.txt`

```
# Exemplo de entradas (uma por linha). Pode usar UPN ou nome SAM.
joao.silva@empresa.com
joaosilva
```

## ▶️ Como Usar

Abra o PowerShell como Administrador e execute:

```powershell
.\disableUsers.ps1
```