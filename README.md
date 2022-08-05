# Welcome to pwnedpass.sh!

Tiny script to bulk check passwords against Troy Hunt's Pwned Passwords.

Although the API for Pwned Passwords has been integrated into a number of
tools, this script is for those that a) don't have those tools, b) want to
control the horizontal and vertical for how passwords are handled, and c)
like scripting.

The API for Pwned Passwords used for this script is documented at
(https://haveibeenpwned.com/API/v2#PwnedPasswords)

# Usage

```
pwnedpass.sh <filename>
```

where:

  `<filename>` is a text file with the following format

```
  Password: <plaintext password>
```

# Warning

Care should be taken with creation, storage, and erasure of plaintext
passwords. `pwnedpass.sh` does not transmit plaintext passwords. However, those
plaintext password are processed in script form and are passed to other
programs which are shown in the dependencies.

**As such, if the system is a multi-user system, or one you cannot and/or do
not control full access to, _DO NOT USE REAL PLAINTEXT PASSWORDS_ with this
script.**

It should be important to note that exposing plaintext passwords in the form
necessary to use the API for Pwned Passwords does come with some risk, but
alone the plaintext password cannot be used without the userid/username and
the corresponding site/URL/account.

# Files Created

During the processing of the input file of plaintext passwords, the following files are created in the same working folder as that from which `pwnedpass.sh` is executed:

- `sha1list.txt`
- `pwdlist.txt`

**These files, along with the input file of plaintext passwords, should be securly erased/deleted upon completion.**

# Example

```
bash$ cat example.txt 
Password: 12345678
Password: yQwqu1C0cZFDAq
bash$ ./pwnedpass.sh example.txt 
12345678 FB2927D828AF22F592134E8932480637C0D:2889079
bash$ 
```

Here, the API for Pwned Passwords was used to test two plaintext passwords with the first plaintext password `12345678` being reported by Pwned Passwords `2889079` times.


# Dependencies

- `sed`: to parse the plaintext password input file
- `sort`: to generate a plaintext password temporary file
- `openssl`: to generate a SHA1 hash of the plaintext password
- `curl`: to invoke the API for Pwned Passwords
- `head`: to report Pwned Passwords hits against the plaintext password


# Task Lists
- [x] OSX
- [x] Debian/Ubuntu
- [ ] CentOS/Fedora (untested)
- [ ] Windows Command Prompt
- [ ] Windows PowerShell
- [ ] add option to perform file clean up after report
- [ ] add secure erase option for files used and created by `pwnedpass.sh`

circa 202208
