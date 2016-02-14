module SkelRelAlgebra where

-- Haskell module generated by the BNF converter

import AbsRelAlgebra
import ErrM
type Result = Err String

failure :: Show a => a -> Result
failure x = Bad $ "Undefined case: " ++ show x

transIdent :: Ident -> Result
transIdent x = case x of
  Ident str  -> failure x


transRels :: Rels -> Result
transRels x = case x of
  RRels rels  -> failure x


transRel :: Rel -> Result
transRel x = case x of
  RTable id  -> failure x
  RSelect cond rel  -> failure x
  RProject projections rel  -> failure x
  RRename renaming rel  -> failure x
  RGroup ids aggregations rel  -> failure x
  RSort ids rel  -> failure x
  RDistinct rel  -> failure x
  RUnion rel1 rel2  -> failure x
  RJoin rel1 rel2  -> failure x
  RThetaJoin rel1 cond2 rel3  -> failure x
  RIntersect rel1 rel2  -> failure x
  RCartesian rel1 rel2  -> failure x
  RExcept rel1 rel2  -> failure x


transCond :: Cond -> Result
transCond x = case x of
  CEq exp1 exp2  -> failure x
  CNEq exp1 exp2  -> failure x
  CLt exp1 exp2  -> failure x
  CGt exp1 exp2  -> failure x
  CLeq exp1 exp2  -> failure x
  CGeq exp1 exp2  -> failure x
  CLike exp1 exp2  -> failure x
  CNot cond  -> failure x
  CAnd cond1 cond2  -> failure x
  COr cond1 cond2  -> failure x


transExp :: Exp -> Result
transExp x = case x of
  EIdent id  -> failure x
  EQIdent id1 id2  -> failure x
  EString str  -> failure x
  EInt n  -> failure x
  EFloat d  -> failure x
  EAggr function id  -> failure x
  EMul exp1 exp2  -> failure x
  EDiv exp1 exp2  -> failure x
  ERem exp1 exp2  -> failure x
  EAdd exp1 exp2  -> failure x
  ESub exp1 exp2  -> failure x


transProjection :: Projection -> Result
transProjection x = case x of
  PExp exp  -> failure x
  PRename exp id  -> failure x


transRenaming :: Renaming -> Result
transRenaming x = case x of
  RRelation id  -> failure x
  RAttributes id ids  -> failure x


transAggregation :: Aggregation -> Result
transAggregation x = case x of
  AApp function id  -> failure x
  ARename function id exp  -> failure x


transFunction :: Function -> Result
transFunction x = case x of
  FAvg  -> failure x
  FSum  -> failure x
  FMax  -> failure x
  FMin  -> failure x
  FCount  -> failure x



