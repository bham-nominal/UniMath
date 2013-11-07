(** **********************************************************

Benedikt Ahrens, Chris Kapulkin, Mike Shulman

january 2013


************************************************************)


(** **********************************************************

Contents :  
                
                Subcategories, Full subcats
                  
                  Image of a functor, full subcat specified
                                       by a functor
                  
                  Subcategories, back to
                    Inclusion functor
                    Full image of a functor
                    Factorization of a functor via its
                       full image
                    This factorization is fully faithful
                       if the functor is
                       [functor_full_img_fully_faithful_if_fun_is]
                                           
                    Isos in full subcategory are equiv
                      to isos in the precategory

                    Full subcategory of a category is 
                      a category
                      [is_category_full_subcat]
                      
                      	   
           
************************************************************)


Require Import Foundations.Generalities.uu0.
Require Import Foundations.hlevel1.hProp.
Require Import Foundations.hlevel2.hSet.

Require Import RezkCompletion.pathnotations.
Import RezkCompletion.pathnotations.PathNotations.

Require Import RezkCompletion.auxiliary_lemmas_HoTT.

Require Import RezkCompletion.precategories.
Require Import RezkCompletion.functors_transformations.

Local Notation "a --> b" := (precategory_morphisms a b)(at level 50).
Local Notation "f ;; g" := (compose f g)(at level 50).
Local Notation "# F" := (functor_on_morphisms F)(at level 3).



(** * Sub-precategories *)

(** A sub-precategory is specified through a predicate on objects 
    and a dependent predicate on morphisms
    which is compatible with identity and composition
*)

Definition is_sub_precategory {C : precategory}
    (C' : hsubtypes (ob C))
    (Cmor' : forall a b:ob C, hsubtypes (a --> b)) :=
dirprod (forall a : ob C,
                         C' a ->  Cmor' _ _ (identity a ))
              (forall (a b c: ob C) (f: a --> b) (g : b --> c),
                   Cmor' _ _ f -> Cmor' _ _  g -> Cmor' _ _  (f ;; g)).

Definition sub_precategories (C : precategory) := total2 (
   fun C' : dirprod (hsubtypes (ob C))
                    (forall a b:ob C, hsubtypes (a --> b)) =>
        is_sub_precategory (pr1 C') (pr2 C')).

(** A full subcategory has the true predicate on morphisms *)

Lemma is_sub_precategory_full (C : precategory)
         (C':hsubtypes (ob C)) :
        is_sub_precategory C' (fun a b => fun f => htrue).
Proof.
  split; simpl;
  intros; exact tt.
Defined.
  
Definition full_sub_precategory {C : precategory}
         (C': hsubtypes (ob C)) :
   sub_precategories C :=
  tpair _  (dirprodpair C' (fun a b f => htrue)) (is_sub_precategory_full C C').


(** We have a coercion [carrier] turning every predicate [P] on a type [A] into the
     total space [ { a : A & P a} ].
   
   For later, we define some projections with the appropriate type, also to 
   avoid confusion with the aforementioned coercion.
*)

Definition sub_precategory_predicate_objects {C : precategory}
     (C': sub_precategories C):
       hsubtypes (ob C) := pr1 (pr1 C').

Definition sub_ob {C : precategory}(C': sub_precategories C): UU :=
     (*carrier*) (sub_precategory_predicate_objects C').


Definition sub_precategory_predicate_morphisms {C : precategory}
        (C':sub_precategories C)
      ( a b:ob C ) : hsubtypes (a --> b) := pr2 (pr1 C') a b.

Definition sub_precategory_morphisms {C : precategory}(C':sub_precategories C)
      (a b : ob C) : UU := 
         (*carrier*) (sub_precategory_predicate_morphisms C' a b).

(** Projections for compatibility of the predicate with identity and
    composition.
*)

Definition sub_precategory_id (C : precategory)(C':sub_precategories C) :
   forall a : ob C,
       sub_precategory_predicate_objects C' a -> 
       sub_precategory_predicate_morphisms  C' _ _ (identity a) :=
         pr1 (pr2 C').

Definition sub_precategory_comp (C : precategory)(C':sub_precategories C) :
   forall (a b c: ob C) (f: a --> b) (g : b --> c),
          sub_precategory_predicate_morphisms C' _ _ f -> 
          sub_precategory_predicate_morphisms C' _ _ g -> 
          sub_precategory_predicate_morphisms C' _ _  (f ;; g) :=
        pr2 (pr2 C').

(** the following lemma should be an instance of a general theorem saying that
     subtypes of a type of hlevel n are of hlevel n, but
     i haven't found that theorem
*)

Lemma is_set_sub_precategory_morphisms {C : precategory}(C':sub_precategories C)
      (a b : ob C) : isaset (sub_precategory_morphisms C' a b).
Proof.
  change (isaset) with (isofhlevel 2).
  apply isofhleveltotal2.
  apply (pr2 (a --> b)).
  intro f.
  apply isasetaprop.
  apply (pr2 (sub_precategory_predicate_morphisms _ _ _ _)).
Qed.

Definition sub_precategory_morphisms_set {C : precategory}(C':sub_precategories C)
      (a b : ob C) : hSet := 
    tpair _ (sub_precategory_morphisms C' a b)
        (is_set_sub_precategory_morphisms C' a b).


(** An object of a subcategory is an object of the original precategory. *)

Definition precategory_object_from_sub_precategory_object (C:precategory)
         (C':sub_precategories C) (a : sub_ob C') : 
    ob C := pr1 a.
Coercion precategory_object_from_sub_precategory_object : 
     sub_ob >-> ob.

(** A morphism of a subcategory is also a morphism of the original precategory. *)

Definition precategory_morphism_from_sub_precategory_morphism (C:precategory)
          (C':sub_precategories C) (a b : ob C)
           (f : sub_precategory_morphisms C' a b) : a --> b := pr1 f .
Coercion precategory_morphism_from_sub_precategory_morphism : 
         sub_precategory_morphisms >-> pr1hSet.


(** ** A sub-precategory forms a precategory. *)

Definition sub_precategory_ob_mor (C : precategory)(C':sub_precategories C) :
     precategory_ob_mor.
Proof.
  exists (sub_ob C').
  exact (fun a b => @sub_precategory_morphisms_set _ C' a b).
Defined.

(*
Coercion sub_precategory_ob_mor : sub_precategories >-> precategory_ob_mor.
*)


Definition sub_precategory_data (C : precategory)(C':sub_precategories C) :
      precategory_data.
Proof.
exists (sub_precategory_ob_mor C C').
split.
  intro c.
  exists (identity (C:=C) (pr1 c)).
  apply sub_precategory_id.
  apply (pr2 c).
  
  intros a b c f g.
  exists (compose (pr1 f) (pr1 g)).
  apply (sub_precategory_comp).
  apply (pr2 f). apply (pr2 g).
Defined.

(** A useful lemma for equality in the sub-precategory. *)

Lemma eq_in_sub_precategory (C : precategory)(C':sub_precategories C)
      (a b : sub_ob C') (f g : sub_precategory_morphisms C' a b) :
          pr1 f == pr1 g -> f == g.
Proof.
  intro H.
  destruct f as [f p].
  destruct g as [g p'].
  apply (total2_paths H).
  simpl. apply proofirrelevance. 
  apply (pr2 (sub_precategory_predicate_morphisms C' a b g)).
Qed.

(*
Lemma eq_in_sub_precategory2 (C : precategory)(C':sub_precategories C)
     (a b : sub_ob C') (f g : a --> b) 
 (pf : sub_precategory_predicate_morphisms C' _ _ f) 
 (pg : sub_precategory_predicate_morphisms C' _ _ g): 
  f == g -> (tpair (fun f => sub_precategory_predicate_morphisms _ _ _ f) f pf) == 
      (tpair (fun f => sub_precategory_predicate_morphisms _ _ _ f) g pg).
Proof.
  intro H.
  apply (total2_paths2 H).
  destruct H.
  apply (total2_paths2 (idpath _ )).
*)

Definition is_precategory_sub_category (C : precategory)(C':sub_precategories C) :
    is_precategory (sub_precategory_data C C').
Proof.
  repeat split;
  simpl; intros.
  unfold sub_precategory_comp.
  apply eq_in_sub_precategory. simpl.
  apply (id_left _ (pr1 a)).
  apply eq_in_sub_precategory. simpl.
  apply (id_right _ (pr1 a)).
  apply eq_in_sub_precategory.
  simpl.
  apply assoc.
Qed.

Definition carrier_of_sub_precategory (C : precategory)(C':sub_precategories C) :
   precategory := tpair _ _ (is_precategory_sub_category C C').

Coercion carrier_of_sub_precategory : sub_precategories >-> precategory.

(** An object satisfying the predicate is an object of the subcategory *)
Definition precategory_object_in_subcat {C : precategory} {C':sub_precategories C}
   (a : ob C)(p : sub_precategory_predicate_objects C' a) :
       ob C' := tpair _ a p.

(** A morphism satisfying the predicate is a morphism of the subcategory *)
Definition precategory_morphisms_in_subcat {C : precategory} {C':sub_precategories C}
   {a b : ob C'}(f : pr1 a --> pr1 b)
   (p : sub_precategory_predicate_morphisms C' (pr1 a) (pr1 b) (f)) :
       precategory_morphisms (C:=C') a b := tpair _ f p.

(** ** Functor from a sub-precategory to the ambient precategory *)

Definition sub_precategory_inclusion_data (C : precategory) (C':sub_precategories C):
  functor_data C' C. 
Proof.
  exists (@pr1 _ _ ). 
  intros a b. 
  exact (@pr1 _ _ ).
Defined.

Definition is_functor_sub_precategory_inclusion (C : precategory) 
         (C':sub_precategories C) :
    is_functor  (sub_precategory_inclusion_data C C').
Proof.
  split;
  simpl; 
  intros.
  apply (idpath _ ).
  apply (idpath _ ).
Qed.

 
Definition sub_precategory_inclusion (C : precategory)(C': sub_precategories C) :
    functor C' C := tpair _ _ (is_functor_sub_precategory_inclusion C C').

(** ** The (full) image of a functor *)

Definition full_img_sub_precategory {C D : precategory}(F : functor C D) :
    sub_precategories D := 
       full_sub_precategory (sub_img_functor F).

(** ** Given a functor F : C -> D, we obtain a functor F : C -> Img(F) *)

Definition full_img_functor_obj {C D : precategory}(F : functor C D) :
   ob C -> ob (full_img_sub_precategory F).
Proof.
  intro c.
  simpl.
  exists (F c).
  simpl.
  intros a b.
  apply b.
  exists c.
  apply identity_iso.
Defined.

Definition full_img_functor_data {C D : precategory}(F : functor C D) :
  functor_data C (full_img_sub_precategory F).
Proof.
  exists (full_img_functor_obj F).
  simpl.
  intros a b f.
  exists (#F f).
  exact tt.
Defined.

Lemma is_functor_full_img (C D: precategory) (F : functor C D) :
  is_functor (full_img_functor_data F).
Proof.
  split; simpl. 
  intro a. 
   assert (H : pr1 (tpair (fun f => htrue) (#F (identity a)) tt ) ==
               pr1 (identity (full_img_functor_obj F a))).
   simpl. apply functor_id.
  apply (total2_paths H).
  apply proofirrelevance.
  apply (pr2 htrue).
  
  intros a b c f g.
  set ( H := eq_in_sub_precategory D (full_img_sub_precategory F)).
  set (H':= H (full_img_functor_obj F a)(full_img_functor_obj F c)).
  apply H'.
  simpl.
  apply functor_comp.
Qed.

Definition functor_full_img {C D: precategory} 
       (F : functor C D) :
   functor C (full_img_sub_precategory F) :=
   tpair _ _ (is_functor_full_img C D F).




(** *** Morphisms in the full subprecat are equiv to morphisms in the precategory *)
(** does of course not need the category hypothesis *)

Definition hom_in_subcat_from_hom_in_precat (C : precategory) 
 (C' : hsubtypes (ob C))
  (a b : ob (full_sub_precategory C'))
      (f : pr1 a --> pr1 b) : a --> b := 
       tpair _ f tt.

Definition hom_in_precat_from_hom_in_full_subcat (C : precategory) 
 (C' : hsubtypes (ob C))
  (a b : ob (full_sub_precategory C')) :
     a --> b -> pr1 a --> pr1 b := @pr1 _ _ .


Lemma isweq_hom_in_precat_from_hom_in_full_subcat (C : precategory) 
 (C' : hsubtypes (ob C))
    (a b : ob (full_sub_precategory C')): 
 isweq (hom_in_precat_from_hom_in_full_subcat _ _ a b).
Proof.
  apply (gradth _ 
         (hom_in_subcat_from_hom_in_precat _ _ a b)).
  intro f. 
  destruct f. simpl.
  apply eq_in_sub_precategory.
  simpl.
  apply idpath.
  intros. apply idpath.
Qed.

Lemma isweq_hom_in_subcat_from_hom_in_precat (C : precategory) 
 (C' : hsubtypes (ob C))
    (a b : ob (full_sub_precategory C')): 
 isweq (hom_in_subcat_from_hom_in_precat  _ _ a b).
Proof.
  apply (gradth _ 
         (hom_in_precat_from_hom_in_full_subcat _ _ a b)).
  intro f. 
  intros. apply idpath.
  intro f.
  destruct f. simpl.
  apply eq_in_sub_precategory.
  simpl.
  apply idpath.
Qed.

Definition weq_hom_in_subcat_from_hom_in_precat (C : precategory) 
     (C' : hsubtypes (ob C))
    (a b : ob (full_sub_precategory C')): weq (pr1 a --> pr1 b) (a-->b) :=
  tpair _ _ (isweq_hom_in_subcat_from_hom_in_precat C C' a b).


Lemma image_is_in_image (C D : precategory) (F : functor C D) 
     (a : ob C):
    is_in_img_functor F (F a).
Proof.
  apply hinhpr.
  exists a.
  apply identity_iso.
Defined.



Lemma functor_full_img_fully_faithful_if_fun_is (C D : precategory)
   (F : functor C D) (H : fully_faithful F) : 
   fully_faithful (functor_full_img F).
Proof.
  unfold fully_faithful in *.
  intros a b.
  set (H' := weq_hom_in_subcat_from_hom_in_precat).
  set (H'' := H' D (is_in_img_functor F)).
(*  assert (Hx : (ob (full_sub_precategory (is_in_img_functor F)))).
      exists (F a).
        simpl. apply hinhpr. exists a. apply idpath. *)
  set (Fa := tpair (fun a : ob D => is_in_img_functor F a) 
        (F a) (image_is_in_image _ _ F a)).
  set (Fb := tpair (fun a : ob D => is_in_img_functor F a) 
        (F b) (image_is_in_image _ _ F b)).
  set (H3 := (H'' Fa Fb)).
  assert (H2 : functor_on_morphisms (functor_full_img F) (a:=a) (b:=b) == 
                  funcomp (functor_on_morphisms F (a:=a) (b:=b))
                          ((H3))).
  apply funextsec. intro f.
  simpl.
  unfold funcomp.
  unfold hom_in_subcat_from_hom_in_precat. simpl.
  unfold invmap.
  apply idpath.

  rewrite H2.
  apply twooutof3c.
  apply H.
  apply (pr2 H3).
Qed.
  
 


(** *** Image factorization C -> Img(F) -> D *)

Lemma functor_full_img_factorization_ob (C D: precategory) 
   (F : functor C D):
  functor_on_objects F == 
  functor_on_objects (functor_composite _ _ _ 
       (functor_full_img F) 
            (sub_precategory_inclusion D _)).
Proof.
  simpl.
  apply etacorrection.
Defined.


(**  works up to eta conversion *)

(*
Lemma functor_full_img_factorization (C D: precategory) 
                (F : functor C D) :
    F == functor_composite _ _ _ (functor_full_img F) 
            (sub_precategory_inclusion D _).
Proof.
  apply functor_eq. About functor_full_img_factorization_ob.
  set (H := functor_full_img_factorization_ob C D F).
  simpl in *.
  destruct F as [F Fax].
  simpl. 
  destruct F as [Fob Fmor]; simpl in *.
  apply (total2_paths2 (H)).
  unfold functor_full_img_factorization_ob in H.
  simpl in *.
  apply dep_funextfunax.
  intro a.
  apply dep_funextfunax.
  intro b.
  apply funextfunax.
  intro f.
  
  generalize Fmor.
  clear Fax.
  assert (H' : Fob == (fun a : ob C => Fob a)).
   apply H.

  generalize dependent a .
  generalize dependent b.
  clear Fmor. 
    generalize H.
  clear H.
  intro H.
  clear H'.
  destruct H.
  tion H.
  induction  H'.
  induction H'.
  clear H.
  
*)


(** ** Any full subprecategory of a category is a category. *)


Section full_sub_cat.

Variable C : precategory.
Hypothesis H : is_category C.

Variable C' : hsubtypes (ob C).


(** *** Isos in the full subcategory are equivalent to isos in the precategory *)

Lemma iso_in_subcat_is_iso_in_precat (a b : ob (full_sub_precategory C'))
       (f : iso a b): is_isomorphism (C:=C) (a:=pr1 a) (b:=pr1 b) 
     (pr1 (pr1 f)).
Proof.
  destruct f as [f fp].
  destruct fp as [g gx]. simpl in *.
  exists g.
(*  destruct f as [f pp]. *)
  destruct gx as [t tp]; simpl in *.
  split; simpl.
  apply (base_paths _ _ t).
  apply (base_paths _ _ tp).
Qed.

Lemma iso_in_precat_is_iso_in_subcat (a b : ob (full_sub_precategory C'))
     (f : iso (pr1 a) (pr1 b)) : 
   is_isomorphism (C:=full_sub_precategory C')  
     (precategory_morphisms_in_subcat f tt).
Proof.
  destruct f as [f fp].
  destruct fp as [g gax].
  destruct gax as [g1 g2].
  exists (precategory_morphisms_in_subcat g tt).
  split; simpl in *.
  apply eq_in_sub_precategory. simpl.
  assumption.
  apply eq_in_sub_precategory. simpl.
  assumption.
Qed.

Definition iso_from_iso_in_sub (a b : ob (full_sub_precategory C'))
       (f : iso a b) : iso (pr1 a) (pr1 b) :=
   tpair _ _ (iso_in_subcat_is_iso_in_precat a b f).

Definition iso_in_sub_from_iso (a b : ob (full_sub_precategory C'))
   (f : iso (pr1 a) (pr1 b)) : iso a b :=
    tpair _ _ (iso_in_precat_is_iso_in_subcat a b f).

Lemma isweq_iso_from_iso_in_sub (a b : ob (full_sub_precategory C')):
     isweq (iso_from_iso_in_sub a b).
Proof.
  apply (gradth _ (iso_in_sub_from_iso a b)).
  intro f.
  apply eq_iso.
  simpl.
  apply eq_in_sub_precategory.
  simpl.
  apply idpath.
  intro f.
  apply eq_iso.
  simpl.
  apply idpath.
Qed.

Lemma isweq_iso_in_sub_from_iso (a b : ob (full_sub_precategory C')):
     isweq (iso_in_sub_from_iso a b).
Proof.
  apply (gradth _ (iso_from_iso_in_sub a b)).
  intro f.
  apply eq_iso.
  simpl.
  apply idpath.
  simpl.
  intro f.
  apply eq_iso.
  simpl.
  apply eq_in_sub_precategory.
  apply idpath.
Qed.




(** *** From Identity in the subcategory to isos in the category  *)
(** This gives a weak equivalence *)

Definition Id_in_sub_to_iso (a b : ob (full_sub_precategory C')):
     a == b -> iso (pr1 a) (pr1 b) :=
       funcomp (precat_paths_to_iso a b) (iso_from_iso_in_sub a b).

Lemma Id_in_sub_to_iso_equal_iso 
  (a b : ob (full_sub_precategory C')) :
    Id_in_sub_to_iso a b == 
funcomp (total_paths2_hProp_equiv C' a b)
        (precat_paths_to_iso (C:=C) (pr1 a) (pr1 b)).
Proof.
  apply funextfunax.
  intro p.
  destruct p.
  apply eq_iso;
  simpl; apply idpath.
Qed.

Lemma isweq_Id_in_sub_to_iso (a b : ob (full_sub_precategory C')):
    isweq (Id_in_sub_to_iso a b).
Proof.
  rewrite Id_in_sub_to_iso_equal_iso.
  apply twooutof3c.
  apply (pr2 (total_paths2_hProp_equiv _ _ _)).
  apply H.
Qed.

(** *** Decomp of map from id in the subcat to isos in the subcat via isos in ambient precat  *)

Lemma precat_paths_in_sub_as_3_maps
   (a b : ob (full_sub_precategory C')):
     precat_paths_to_iso a b == funcomp (Id_in_sub_to_iso a b) 
                                        (iso_in_sub_from_iso a b).
Proof.
  apply funextfunax.
  intro p.
  destruct p.
  simpl.
  apply eq_iso.
  simpl.
  unfold precategory_morphisms_in_subcat.
  apply eq_in_sub_precategory.
  simpl.
  apply idpath.
Qed.

(** *** The aforementioned decomposed map is a weak equivalence  *)

Lemma isweq_sub_precat_paths_to_iso 
  (a b : ob (full_sub_precategory C')) :
 isweq (precat_paths_to_iso a b).
Proof.
  rewrite precat_paths_in_sub_as_3_maps.
  apply twooutof3c.
  apply isweq_Id_in_sub_to_iso.
  apply isweq_iso_in_sub_from_iso.
Qed.

(** ** Proof of the targeted theorem: full subcats of cats are cats *)

Lemma is_category_full_subcat: is_category (full_sub_precategory C').
Proof.
  unfold is_category.
  apply isweq_sub_precat_paths_to_iso.
Qed.


End full_sub_cat.


Lemma functor_full_img_essentially_surjective (A B : precategory)
     (F : functor A B) :
  essentially_surjective (functor_full_img F).
Proof.
  intro b.
  apply (pr2 b).
  intros [c h].  
  intros q Hq.
  apply Hq.
  exists c.
  apply iso_in_sub_from_iso.
  apply h.
Qed.
