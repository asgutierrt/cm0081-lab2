{- | Module containing the function getInfo.

     Takes a .txt file with the Git commits of a project
     and returns a .csv file with the information of each
     commit.
     
     Authors: Ana Sofía Gutiérrez, Manuela Zapata Mesa
     (2020)
-}
module GetCommitsInfo (
    -- * Main function
    getInfo,
    -- * Main support functions
    listPairs, newCm, infoCm, sepLines,
    -- * Functions that process Strings with Regex
    message, gpg, email, nombre, idname,
    -- * Auxiliary functions
    get1, get2, get3
    ) where
import System.IO
import Data.Csv
import qualified Data.ByteString.Lazy as BSL
import Text.Regex.TDFA
import Data.List as Ls
import Data.Text as Tx (dropEnd, pack, unpack, strip)
{-| Receives a line and returns a message if there.
    Using the regular espression
@
"[^[[:space:]]]*"
@
    to know the format of a message line
-}
message :: String -> String
message a
    | get1 b == "    " = Tx.unpack (Tx.dropEnd 1 (Tx.pack (get2 b ++ get3 b)))
    | otherwise        = ""
               where b = a =~ "[^[[:space:]]]*" :: (String, String, String)

{-| Receives a line and returns if GPG signed.
    Using the regular espression
@
"[a-z]+"
@
    to extract the header of the line and compares it with "gpgsig"
-}
gpg :: String -> String
gpg a
    | get2 b == "gpgsig" = "Yes"
    | otherwise          = "No"
                 where b = a =~ "[a-z]+" :: (String, String, String)

{-| Receives a line and returns an email from the given argument 'encabezado'.
    Using the regular espression
@
"[a-zA-Z0-9+._-]+@[a-zA-Z0-9+._-]+\\.[a-z]+"
@
    to know the format of an email
-}
email :: String -> String -> String
email a encabezado
    | get2 b == encabezado = e
    | otherwise            = ""
    where b = a =~ "[a-z]+" :: (String, String, String)
          c = get3 (get3 b =~ "<" :: (String, String, String))
          d = get2 (c =~"[a-zA-Z0-9+._-]+@[a-zA-Z0-9+._-]+\\.[a-z]+"
                      ::(String, String, String))
          e = get1 (d =~ ">" :: (String, String, String))

{-| Receives a line and returns the name of the author or commiter
    depending on the argument.
    Using the regular espression
@
"[a-z]+"
@
    to extract the header of the line and compares it with the header
    argument
-}

nombre :: String -> String-> String
nombre a encabezado
    | get2 b == encabezado = d
    | otherwise            = ""
                   where b = a =~ "[a-z]+" :: (String, String, String)
                         c = get3 b =~ "<" :: (String, String, String)
                         d = Tx.unpack (Tx.strip (Tx.pack (get1 c)))

{-| Recieves a line and returns an ID.
    Using the regular espression
@
"[a-z0-9]+"
@
    to know the format of an Id line
-}
idname :: String -> String -> String
idname a encabezado
    | get2 b == encabezado = get3 b =~ "[a-z0-9]+" :: String
    | otherwise            = ""
                   where b = a =~ "[a-z]+" :: (String, String, String)


-- | Gets the first element in index of a 3-tuple
get1 :: (String, String, String) -> String
get1 (a,_,_) = a

-- | Gets the second element in index of a 3-tuple
get2 :: (String, String, String) -> String
get2 (_,b,_)=b

-- | Gets the third element in index of a 3-tuple
get3 :: (String, String, String) -> String
get3 (_,_,c)=c


-- | Returns a list with the number of the commit each line belongs to
-- The 'k', 'key' arguments must have default value of 0.
listPairs :: [String] -> Int -> Int -> [(Int, String)]
listPairs lineas k key
    | k == length lineas  = []
    | otherwise           = entrada ++ listPairs lineas (k+1) key2
            where entrada = [(key2, lineas!!k)]
                  key2    = if newCm (lineas!!k) then key+1
                            else key

-- | To know whether a line is the start of a new commit
newCm :: String -> Bool
newCm linea = (linea =~ "[a-z]+" :: String) =="commit"

-- | Finds the information in the lines of a single commit
-- The 'k', 'key', 'm' arguments must have default value of 0.
infoCm :: [(Int, String)]-> Int -> Int -> Int -> [String]
infoCm lista k key m
    | key == 0 = if [commit] == [""]
                    then infoCm lista (k+1) key m
                 else commit : infoCm lista (k+1) (key+1) (m+1)
    | key == 1 = if [parent] == [""] && (k+1)<length lista
                    then infoCm lista (k+1) key m
                 else parent : infoCm lista m (key+1) (m+1)
    | key == 2 = if [author] == [""] && (k+1)<length lista
                    then infoCm lista (k+1) key m
                 else [author] ++ [correo] ++ infoCm lista m (key+1) (m+1)
    | key == 3 = if [committer] == [""] && (k+1)<length lista
                    then infoCm lista (k+1) key m
                 else committer : infoCm lista m (key+1) (m+1)
    | key == 4 = if [gpgsig] == ["No"] && (k+1)<length lista
                    then infoCm lista (k+1) key m
                 else gpgsig : infoCm lista m (key+1) (m+1)
    | key == 5 = if [mess] == [""] && (k+1)<length lista
                    then infoCm lista (k+1) key m
                 else mess : infoCm lista m (key+1) (m+1)
    | otherwise = []
                where author    = nombre (snd (lista!!k)) "author"
                      parent    = idname (snd (lista!!k)) "parent"
                      commit    = idname (snd (lista!!k)) "commit"
                      correo    = email (snd (lista!!k)) "author"
                      committer = nombre (snd (lista!!k)) "committer"
                      gpgsig    = gpg (snd (lista!!k))
                      mess      = message (snd (lista!!k))

{- | Separates the lines of the file in individual commits
     and finds the information on each with the 'infoCm' function
-}
-- The 'k' argument must have default value of 1.
sepLines :: [(Int, String)] -> Int -> [[String]]
sepLines lista k
    | (k-1) == Ls.maximum (Ls.map fst lista) = []
    | otherwise          = entrada : sepLines lista (k+1)
        where commitsInK = filter (\x -> fst x == k) lista
              cmm        = infoCm commitsInK 0 0 0
              entrada    = [cmm!!2]++([cmm!!4]++([cmm!!3]
                           ++([head cmm]++([cmm!!1]++([cmm!!5]++[cmm!!6])))))

{- |The function: 'getInfo' reads the given file
    with the 'System.IO' package and passes the contents to 'sepLines'.
    The function returs a list of strings that are converted to a .csv
    file with the 'Data.ByteString.Lazy' package.
-}
getInfo :: FilePath -> FilePath -> IO ()
getInfo name1 name2 = do
    handle      <-  openFile name1 ReadMode
    hSetEncoding handle utf8
    contents    <- hGetContents handle
    let lineas  = lines contents
        in BSL.writeFile name2 $ encode
                     (title : sepLines (listPairs lineas 0 0) 1)
        where title = ["Author", "Commiter", "Author Email",
                        "Commit Id", "Parent","GPG Signed?", "Commit Message"]
