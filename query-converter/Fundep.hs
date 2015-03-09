module Fundep where

-- straightforward, unoptimized algorithms for functional dependencies and normal forms
-- work fine for relations with any reasonable number of attributes

type Attr     = String
type Fundep   = ([Attr], Attr)
type Relation = ([Attr], [Fundep])

-- the closure of attrs in allAttrs, given deps
closure :: Relation -> [Attr] -> [Attr]
closure (allAttrs, deps) attrs = iter attrs where
  iter xs = let xs2 = add xs in if xs2 == xs then xs else iter xs2
  add  xs = xs ++ [a | a <- allAttrs, not (elem a xs), follows deps xs a]

-- whether a is determined by xs, given deps
follows :: [Fundep] -> [Attr] -> Attr -> Bool
follows deps xs a = or [all (flip elem xs) args | (args,b) <- deps, b == a]

-- the transitive closure of functional dependencies
closureFundep :: Relation -> [Fundep]
closureFundep rel@(allAttrs,deps) = [(xs, a) | xs <- subsets allAttrs, a <- closure rel xs, notElem a xs] 

-- attrs is a superkey, if allAttrs is included in the closure of attrs
isSuperkey :: Relation -> [Attr] -> Bool
isSuperkey rel@(allAttrs, deps) attrs = all (flip elem (closure rel attrs)) allAttrs

-- attrs is a key, if it is a superkey
--                    and any list where any of its attributes is removed is no longer a superkey  
isKey :: Relation -> [Attr] -> Bool
isKey rel@(allAttrs,deps) attrs = isSuperkey rel attrs
                               && not (any (isSuperkey rel) [filter (/=a) attrs | a <- attrs])

-- find all subsets to test e.g. what keys there are
subsets :: [Attr] -> [[Attr]]
subsets attrs = map concat (sequence [[[],[a]] | a <- attrs])

-- all superkeys
superkeys :: Relation -> [[Attr]]
superkeys rel@(allAttrs, deps) = [attrs | attrs <- subsets allAttrs, isSuperkey rel attrs]

-- all keys
keys :: Relation -> [[Attr]]
keys rel@(allAttrs,deps) = [attrs | attrs <- superkeys rel, isKey rel attrs]

-- an attribute is prime if it belongs to some key
isPrime :: Relation -> Attr -> Bool
isPrime rel attr = elem attr (concat (keys rel))

-- find violations of the Boyce-Codd Normal Form
violateBCNF :: Relation -> [Fundep]
violateBCNF rel@(allAttrs,deps) = [dep | dep@(args,val) <- closureFundep rel, not (isSuperkey rel args)]

-- check if a relation is in the Boyce-Codd Normal Form
isBCNF :: Relation -> Bool
isBCNF rel = null (violateBCNF rel)

-- find violations of the Third Normal Form
violate3NF :: Relation -> [Fundep]
violate3NF rel@(allAttrs,deps) = [dep | dep@(args,val) <- closureFundep rel, not (isSuperkey rel args || isPrime rel val)]

-- check if a relation is in the Third Normal Form
is3NF :: Relation -> Bool
is3NF rel = null (violateBCNF rel)

-- bring relation to BCNF
normalizeBCNF :: Relation -> [Relation]
normalizeBCNF rel = case violateBCNF rel of
  [] -> [rel]
  f:fs -> concatMap normalizeBCNF (decompose f rel)
 where
  decompose (xs,a) rel@(attrs,fundeps) = let 
                                            cxs = closure rel xs
                                            noncxs = filter (\a -> notElem a cxs || elem a xs) attrs
                                         in [restrictRel rel cxs, restrictRel rel noncxs]

restrictRel :: Relation -> [Attr] -> Relation
restrictRel rel@(_,fundeps) attrs = (attrs, [(xs,a) | (xs,a) <- fundeps, all (flip elem attrs) (a:xs)])


------------ printing and parsing

-- get a relation from a list of lines: the attribute list plus a list of functional dependencies
pRelation :: [String] -> Relation
pRelation (s:ss) = (words s, concatMap pDeps ss)

-- get a set of fundeps from a string of the form "A B C -> D E" ; spaces around elements required
pDeps :: String -> [Fundep]
pDeps s = case break (=="->") (words s) of
  (args@(_:_), _:vals@(_:_)) -> [(args,val) | val <- vals]
  _ -> []

prFundep :: Fundep -> String
prFundep (xs,a) = unwords (xs ++ ["->", a])

prRelation :: Relation -> String
prRelation (attrs,fundeps) = unlines (
  "Attributes:" :
  unwords attrs :
  "":
  "Functional dependencies:" :
  map prFundep fundeps
  )

prRelationInfo :: Relation -> String
prRelationInfo rel@(attrs,fundeps) = unlines [
  prRelation rel,
  "Derived functional dependencies:",
  unlines (map prFundep (filter (flip notElem fundeps) (closureFundep rel))),
  "Superkeys:",
  unlines (map unwords (superkeys rel)),
  "Keys:",
  unlines (map unwords (keys rel)),
  "BCNF violations:",
  unlines (map prFundep (violateBCNF rel)),
  "3NF violations:",
  unlines (map prFundep (violate3NF rel))
  ]
 


