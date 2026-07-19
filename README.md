# 💳 BSRP Banking

A modern banking system built exclusively for the **BSRP Framework**.

BSRP Banking provides secure player financial management, including bank accounts, transactions, and money handling while integrating directly with the BSRP ecosystem. Designed for performance, reliability, and seamless roleplay integration, it provides the foundation for player economy systems across BSRP resources.

---

## Features

* 💳 Player bank accounts
* 💵 Cash and bank balance management
* ➕ Deposit money
* ➖ Withdraw money
* 🔄 Player-to-player transactions
* 📊 Transaction tracking
* 🔒 Secure server-side validation
* ⚡ Optimized performance
* 🔗 Full BSRP Framework integration

---

## Framework Requirements

This resource requires:

* BSRP Framework
* oxmysql
* ox_lib

Recommended:

* ox_inventory
* bsrp-characters
* bsrp-phone
* bsrp-jobs

---

## Installation

### 1. Place Resource

```text
resources/
└── bsrp-banking/
```

### 2. Ensure Dependencies

```cfg
ensure oxmysql
ensure ox_lib
ensure bsrp

ensure bsrp-banking
```

> BSRP Banking must start after the `bsrp` core resource.

---

## Database

Import the provided SQL file if included:

```sql
sql/bsrp-banking.sql
```

If automatic database initialization is enabled, required tables will be created automatically.

---

## Configuration

Configuration options can be found in:

```text
config.lua
```

Available settings may include:

* Starting bank balance
* Transaction limits
* Banking locations
* Account settings
* Permission settings
* Notification options

---

## Banking System

### View Account

Players can:

* Check current balance
* View account information
* Access banking services
* Manage personal funds

### Deposit Money

Players can:

* Deposit cash into their bank account
* Secure funds for later use
* Track financial activity

### Withdraw Money

Players can:

* Withdraw available funds
* Receive cash instantly
* Manage personal finances

### Transfers

Players can:

* Send money to other players
* Complete secure transactions
* Verify transfer information

---

## Banking Data

Each account stores:

* Character Identifier
* Bank Balance
* Transaction History
* Account Information
* Financial Records

---

## Framework Integration

### Get Player Banking Data

```lua
local player = exports.bsrp:GetPlayer(source)

if player then
    print(player.money.bank)
end
```

### Add Bank Money

```lua
player.Functions.AddMoney('bank', amount)
```

### Remove Bank Money

```lua
player.Functions.RemoveMoney('bank', amount)
```

---

## Banking Events

Example usage:

```lua
RegisterNetEvent('bsrp:bankingOpened', function()
    print('Banking interface opened.')
end)
```

```lua
RegisterNetEvent('bsrp:bankingTransaction', function()
    print('Transaction completed.')
end)
```

> Event names may vary depending on implementation.

---

## Permissions

Administrative banking actions can utilize the BSRP permission system:

```lua
if exports.bsrp:IsAdmin(source, 2) then
    -- Banking administration actions
end
```

---

## Compatibility

| Resource          | Supported |
| ----------------- | --------- |
| BSRP Framework    | ✅         |
| oxmysql           | ✅         |
| ox_lib            | ✅         |
| ox_inventory      | ✅         |
| bsrp-characters   | ✅         |
| bsrp-phone        | ✅         |
| bsrp-jobs         | ✅         |

---

## Banking Lifecycle

### Player Connects

1. Player joins the server
2. Character data is loaded
3. Banking information is retrieved
4. Account becomes available

### Banking Access

1. Player opens banking menu
2. Account information is loaded
3. Transactions are validated
4. Banking actions are processed

### Banking Saves

Banking data is automatically saved during:

* Transactions
* Character switching
* Player logout
* Server restart

---

## Development

When creating resources that depend on banking information:

```lua
local player = exports.bsrp:GetPlayer(source)

if not player then
    return
end

local bank = player.money.bank
```

Always verify banking actions server-side before processing financial transactions.
