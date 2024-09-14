# Hibabejelento
<!-- TOC -->
- [Hibabejelento](#hibabejelento)
        - [SetHostData SetHostData.ps1](#sethostdata-sethostdataps1)
            - [Szükséges beállítások az első használat előtt:](#sz%C3%BCks%C3%A9ges-be%C3%A1ll%C3%ADt%C3%A1sok-az-els%C5%91-haszn%C3%A1lat-el%C5%91tt)
            - [Használat](#haszn%C3%A1lat)
        - [SendHostData SendHostData.ps1](#sendhostdata-sendhostdataps1)
            - [Szükséges beállítások az első használat előtt:](#sz%C3%BCks%C3%A9ges-be%C3%A1ll%C3%ADt%C3%A1sok-az-els%C5%91-haszn%C3%A1lat-el%C5%91tt)
            - [Használat](#haszn%C3%A1lat)

<!-- /TOC -->

### SetHostData (SetHostData.ps1)

Ez a powershell script arra szolgál, hogy az átadott paraméterek alapján létrehozzon egy kulcsot a regisztrációs adatbázisban, majd ezután elhelyezzen egy parancsikont az aktuálisan belépett user asztalán, ami meghívja az adatküldő (SendHostData.ps1) scriptet megfelelő paraméterekkel.

A következő bemeneti string paraméterrel rendelkezik, ezek mindegyike szükséges ahhoz, hogy megfelelően működjön.

- `Company`: annak a cégnek a neve, amelyikhez tartozik a hibás számítógép, amire hibát szeretnénk rögzíteni.
- `Hostname`: annak a hostnak a neve, amelyre vonatkozóan szeretnénk bejegyzéseket rögzíteni.
- `Username`: annak a usernek a neve, akit szeretnénk az adott hostra beállítani, mint username
- `Password`: annak a usernek a jelszava, amelyet szeretnénk az adott hoston használni. `Figyelem: a jelszót titkosítás nélküli plain-textben tárolja regisztrációs adatbázis, bárki, aki hozzáfér a regisztrációs adatbázishoz, olvashatja azt!`

#### Szükséges beállítások az első használat előtt:
- `$appName`: annak az applikációnak a neve, amelyet szeretnénk használni a regisztrációs adatbázisban szereplő kulcsként. A `Hostname`-ként megadott érték ennek a bejegyésnek lesz a gyermeke.

#### Használat

>Fontos, hogy  a scriptet rendszergazda jogosultságokkal szükséges futtatni annak érdekében, hogy a megfelelő helyre tudjon új regisztrációs adatbázis kulcsot létrehozni. Ez eredendően a **HKLM (HKEY_LOCAL_MACHINE)**, azonban ez szabadon átírható a scriptben.
Nyissuk meg a powershell scriptet admin jogokkal, majd futtasuk a következő parancsot:

```
.\SetHostData.ps1 -Hostname "elso-gep" -Company "cégnév" -Username "elso-felhasznalo" -Password "titkosjelszo"
```
---
### SendHostData (SendHostData.ps1)

Ez a script kiolvassa a `SetHostData.ps1` scripttel beállított regisztrációs adatbázis kulcsából a felhasználó nevet és jelszót, majd generál egy alap bejelentkezési formot, amit aztán automatikusan submitol. Ennek hatására úgy lehet bejelentkezni egy targetként megadott oldalra, hogy a felhasználónak nem szükséges bevinnie manuálisan a felhasználó nevet és jelszót.
>FIGYELEM: habár a kommunikáció https-en történik mégis fokozott tekintettel kell lenni arra, hogy a jelszó titkosítatlanul, plain-textben tárolódik a regisztrációs adatbázisban.

#### Szükséges beállítások az első használat előtt:
- `$appName`: annak az applikációnak a neve, amelyet a regisztrációs kulcs nevében használunk (jobb esetben a `SetHostData.ps1` scriptben beállított)
- `$url`: az az url, amelyet post method segítségével szeretnénk meghívni (pl: https://sajat.domain.hu/login)

#### Használat
A scriptet nem szükséges rendszergazdai jogosultságokkal futtatni, az a fontos, hogy olvasni tudja a kívánt regisztrációs adatbázis kulcsot.

```
.\SendHostData.ps1 -Hostname "elso-gep"
```

Ha valaki parancsikont szeretne létrehozni, annak érdekében, hogy könnyebben, gyorsabban meg lehessen nyitni a kívánt oldalt, akkor windows rendszereken a parancsikon célja a következő lehet:
```
C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -File "C:\Users\Public\Documents\ocsipc\SendHostData.ps1" -Hostname "elso-gep"
