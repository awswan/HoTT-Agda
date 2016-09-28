{-# OPTIONS --without-K #-}

open import HoTT
open import homotopy.FunctionOver
open import homotopy.PtdMapSequence
-- open import groups.HomSequence
-- open import groups.ExactSequence

module cohomology.CofiberSequence {i} where

{- Useful abbreviations -}
module _ {X Y : Ptd i} (f : X ⊙→ Y) where

  ⊙Cof² = ⊙Cof (⊙cfcod' f)
  ⊙cfcod²' = ⊙cfcod' (⊙cfcod' f)

  ⊙Cof³ = ⊙Cof ⊙cfcod²'
  ⊙cfcod³' = ⊙cfcod' ⊙cfcod²'

module _ {A B : Type i} (f : A → B) where

  Cof² = Cofiber (cfcod' f)
  cfcod²' = cfcod' (cfcod' f)

  Cof³ = Cofiber cfcod²'
  cfcod³' = cfcod' cfcod²'

{- For [f : X → Y], the cofiber space [Cof(cfcod f)] is equivalent to
 - [Suspension X]. This is essentially an application of the two pushouts
 - lemma:
 -
 -       f
 -   X ––––> Y ––––––––––––––> ∙
 -   |       |                 |
 -   |       |cfcod f          |
 -   v       v                 v
 -   ∙ ––> Cof f ––––––––––> Cof² f
 -                cfcod² f
 -
 - The map [cfcod² f : Cof f → Cof² f] becomes [extract-glue : Cof f → ΣX],
 - and the map [cfcod³ f : Cof² f → Cof³ f] becomes [Susp-fmap f : ΣX → ΣY].
 -}
private
  {- the equivalences between [Cof² f] and [ΣX] (and so [Cof³ f] and [ΣY]) -}
  module Equiv {X Y : Ptd i} (f : X ⊙→ Y) where

    module Into = CofiberRec {f = cfcod' (fst f)} {C = Susp (fst X)}
      south extract-glue (λ _ → idp)

    into : Cof² (fst f) → Susp (fst X)
    into = Into.f

    ⊙into : ⊙Cof² f ⊙→ ⊙Susp X
    ⊙into = into , ! (merid (snd X))

    module Out = SuspensionRec {C = fst (⊙Cof² f)}
      (cfcod cfbase) cfbase
      (λ x → ap cfcod (cfglue x) ∙ ! (cfglue (fst f x)))

    out : Susp (fst X) → Cof² (fst f)
    out = Out.f

    into-out : ∀ σ → into (out σ) == σ
    into-out = Suspension-elim idp idp
      (λ x → ↓-∘=idf-in into out $
        ap (ap into) (Out.merid-β x)
        ∙ ap-∙ into (ap cfcod (cfglue x)) (! (cfglue (fst f x)))
        ∙ ap (λ w → ap into (ap cfcod (cfglue x)) ∙ w)
             (ap-! into (cfglue (fst f x)) ∙ ap ! (Into.glue-β (fst f x)))
        ∙ ∙-unit-r _
        ∙ ∘-ap into cfcod (cfglue x) ∙ ExtractGlue.glue-β x)

    out-into : ∀ κ → out (into κ) == κ
    out-into = Cofiber-elim {f = cfcod' (fst f)}
      idp
      (Cofiber-elim {f = fst f} idp cfglue
        (λ x → ↓-='-from-square $
          (ap-∘ out extract-glue (cfglue x)
           ∙ ap (ap out) (ExtractGlue.glue-β x) ∙ Out.merid-β x)
          ∙v⊡ (vid-square {p = ap cfcod (cfglue x)}
               ⊡h rt-square (cfglue (fst f x)))
          ⊡v∙ ∙-unit-r _))
      (λ y → ↓-∘=idf-from-square out into $
         ap (ap out) (Into.glue-β y) ∙v⊡ connection)

    eqv : Cof² (fst f) ≃ Susp (fst X)
    eqv = equiv into out into-out out-into

    ⊙eqv : ⊙Cof² f ⊙≃ ⊙Susp X
    ⊙eqv = ≃-to-⊙≃ eqv (! (merid (snd X)))

module _ {X Y : Ptd i} (f : X ⊙→ Y) where

  private
    square₁ : PtdMapCommSquare (⊙cfcod²' f) ⊙extract-glue (⊙idf _) (Equiv.⊙into f)
    square₁ = record {commutes = λ _ → idp}

    square₂ : PtdMapCommSquare (⊙cfcod³' f) (⊙Susp-fmap f)
      (Equiv.⊙into f) (⊙Susp-flip Y ⊙∘ Equiv.⊙into (⊙cfcod' f))
    square₂ = record {
      commutes = Cofiber-elim {f = cfcod' (fst f)}
        idp
        (Cofiber-elim {f = fst f}
          idp (λ y → merid y)
          (λ x → ↓-cst=app-in $
              ap (idp ∙'_)
                ( ap-∘ (Susp-fmap (fst f)) extract-glue (cfglue x)
                ∙ ap (ap (Susp-fmap (fst f))) (ExtractGlue.glue-β x)
                ∙ SuspFmap.merid-β (fst f) x)
            ∙ ∙'-unit-l (merid (fst f x))))
        (λ y → ↓-='-in (
            ap (Susp-fmap (fst f) ∘ Equiv.into f) (cfglue y)
              =⟨ ap-∘ (Susp-fmap (fst f)) (Equiv.into f) (cfglue y) ⟩
            ap (Susp-fmap (fst f)) (ap (Equiv.into f) (cfglue y))
              =⟨ Equiv.Into.glue-β f y |in-ctx ap (Susp-fmap (fst f)) ⟩
            idp
              =⟨ ! $ !-inv'-l (merid y) ⟩
            ! (merid y) ∙' merid y
              =⟨ ! $ SuspFlip.merid-β y |in-ctx _∙' merid y ⟩
            ap Susp-flip (merid y) ∙' merid y
              =⟨ ! $ ExtractGlue.glue-β y |in-ctx (λ p → ap Susp-flip p ∙' merid y) ⟩
            ap Susp-flip (ap extract-glue (cfglue y)) ∙' merid y
              =⟨ ! $ ap-∘ Susp-flip extract-glue (cfglue y) |in-ctx _∙' merid y ⟩
            ap (Susp-flip ∘ extract-glue) (cfglue y) ∙' merid y
              =∎))}

  Cof²-equiv-Susp-dom : Cof² (fst f) ≃ Susp (fst X)
  Cof²-equiv-Susp-dom = Equiv.eqv f

  ⊙Cof²-equiv-⊙Susp-dom : ⊙Cof² f ⊙≃ ⊙Susp X
  ⊙Cof²-equiv-⊙Susp-dom = Equiv.⊙eqv f

  cofiber-seq-map : PtdMapSeqMap
    (⊙Cof f ⊙→⟨ ⊙cfcod²' f ⟩ ⊙Cof² f ⊙→⟨ ⊙cfcod³' f ⟩ ⊙Cof³ f ⊙⊣|)
    (⊙Cof f ⊙→⟨ ⊙extract-glue ⟩ ⊙Susp X ⊙→⟨ ⊙Susp-fmap f ⟩ ⊙Susp Y ⊙⊣|)
    (⊙idf (⊙Cof f)) (⊙Susp-flip Y ⊙∘ Equiv.⊙into (⊙cfcod' f))
  cofiber-seq-map = ⊙idf (⊙Cof f) ⊙↓⟨ square₁ ⟩ _ ⊙↓⟨ square₂ ⟩ _ ⊙↓|

  cofiber-seq-map-is-equiv : is-⊙seq-equiv cofiber-seq-map
  cofiber-seq-map-is-equiv = idf-is-equiv _ , snd (Equiv.eqv f)
                           , snd (Susp-flip-equiv ∘e (Equiv.eqv (⊙cfcod' f)))
