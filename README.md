## Names
Ana Sofia Gutierrez, Manuela Zapata Mesa
## General description
Module containing the function getInfo which

Takes a .txt file with the Git Commits of a project and returns
a .csv file with the information of each commit

```haskell
getInfo :: DFA s c -> Int -> Int
```
The text file is defined by the commits syntaxis used by Git and the
returned .csv file has the format

<Author>,<Committer>,<Author Email>,<Commit ID>,<Parent>,<GPG Signed?>,<Commit Message>

## How to use it
### Packages
Add to the ghc packages using `$ cabal update && cabal install`
```haskell
import Text.Regex.TDFA
```

### Use
Load the code with
  $ ghc GetCommitsInfo.hs
  $.\getInfo nameTXT nameCSV

The program reads the contents in `nameTXT` line by line and 
process them using regular expresions from the 
[regex-tdfa](http://hackage.haskell.org/package/regex-tdfa) library.
The contents are written in a .csv file named `nameCSV`.

## Used Versions
OS Microsoft Windows 10 Home Version 10.0.18363

GHC, version 8.10.1

[HLint](https://hackage.haskell.org/package/hlint) v3.1.6, 
(C) Neil Mitchell 2006-2020
