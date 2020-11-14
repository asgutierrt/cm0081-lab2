# Programming Lab 2: Git Commits in a Repository
### Names
Ana Sofia Gutiérrez, Manuela Zapata Mesa
## General description
Module containing the function getInfo which

Takes a .txt file with the Git Commits of a project and returns
a .csv file with the information of each commit.

```haskell
getInfo :: FilePath -> FilePath -> IO()
```
The text file is defined by the commits syntaxis used by Git and the
returned .csv file has the format.

`<Author>,<Committer>,<Author Email>,<Commit ID>,<Parent>,<GPG Signed?>,<Commit Message>`

## How to use it
### Packages
The following libraries are used in the program
* `regex-tdfa`
* `cassava`

Add to the ghc packages using `$ cabal update` 
and `$ cabal install`.

### Usage
Load the code with

`$ ghc GetCommitsInfo.hs`
  
`$.\getInfo nameTXT.txt nameCSV.csv`
  

The program takes the contents in the `nameTXT.txt` file saved in the same 
directory as the program. It reads it line by line and 
process them using regular expresions from the 
[regex-tdfa](http://hackage.haskell.org/package/regex-tdfa) library.
The contents are written in a .csv file named `nameCSV.csv` using the 
[cassava](https://hackage.haskell.org/package/cassava) library.

## Versions
OS Microsoft Windows 10 Home Version 10.0.18363

GHC, version 8.10.1

[HLint](https://hackage.haskell.org/package/hlint) v3.1.6, 
(C) Neil Mitchell 2006-2020
