(** Copyright (c) 2018 by Karl Crary

  Permission is hereby granted, free of charge, to any person obtaining
  a copy of this software and associated documentation files (the
  "Software"), to deal in the Software without restriction, including
  without limitation the rights to use, copy, modify, merge, publish,
  distribute, sublicense, and/or sell copies of the Software, and to
  permit persons to whom the Software is furnished to do so, subject to
  the following conditions:

  The above copyright notice and this permission notice shall be
  included in all copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
  BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
  ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
  CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
  SOFTWARE.
*)

Require Export Relation_Definitions.

Require Import Tact.


(** reflexive, transitive closure *)
Inductive star {T : Type} (R : T -> T -> Prop) : T -> T -> Prop :=
| star_refl {x}
    : star R x x

| star_step {x y z}
    : R x y
      -> star R y z
      -> star R x z.


Inductive starr {T : Type} (R : T -> T -> Prop) : T -> T -> Prop :=
| starr_refl {x}
    : starr R x x

| starr_step {x y z}
    : starr R x y
      -> R y z
      -> starr R x z.


Lemma star_trans :
  forall (T : Type) (R : T -> T -> Prop) x y z,
    star R x y
    -> star R y z
    -> star R x z.
Proof.
intros T R x y z Hxy Hyz.
revert z Hyz.
induct Hxy; eauto.
intros x y z Hxy _ IH.
intros.
eapply star_step; eauto.
Qed.


Lemma star_transitive :
  forall (T : Type) (R : T -> T -> Prop),
    transitive T (star R).
Proof.
exact star_trans.
Qed.


Lemma star_one :
  forall (T : Type) (R : T -> T -> Prop) x y,
    R x y -> star R x y.
Proof.
intros T R x y H.
eapply star_step; eauto using star_refl.
Qed.


Lemma star_stepr :
  forall (T : Type) (R : T -> T -> Prop) x y z,
    star R x y
    -> R y z
    -> star R x z.
Proof.
intros.
eapply star_trans; eauto.
apply star_one; auto.
Qed.


Lemma star_mono :
  forall (T : Type) (R R' : T -> T -> Prop),
    (forall x y, R x y -> R' x y)
    -> forall x y, star R x y -> star R' x y.
Proof.
intros T R R' HR x y Hxy.
induct Hxy.

(** refl *)
{
intro.
apply star_refl.
}

(** step *)
{
intros x y z Hxy _ IH.
eapply star_step; eauto.
}
Qed.


Lemma star_map :
  forall (S T : Type) (R : S -> S -> Prop) (R' : T -> T -> Prop) (f : S -> T),
    (forall x y, R x y -> R' (f x) (f y))
    -> forall x y, star R x y -> star R' (f x) (f y).
Proof.
intros S T R R' f HR x y Hxy.
induct Hxy.

(** refl *)
{
intros x.
apply star_refl.
}

(** step *)
{
intros x y z Hxy _ IH.
eapply star_step; eauto.
}
Qed.


Lemma star_starr :
  forall (T : Type) (R : T -> T -> Prop) x y,
    star R x y
    -> starr R x y.
Proof.
intros T R x y Hstar.
assert (starr R x x) as Hacc by (apply starr_refl).
remember x as z in Hacc at 1 |- * at 1.
clear Heqz; revert Hacc.
induct Hstar.

(** refl *)
{
intros x Hacc.
assumption.
}

(** step *)
{
intros x y w HR _ IH Hacc.
apply IH.
eapply starr_step; eauto.
}
Qed.


Lemma starr_star :
  forall (T : Type) (R : T -> T -> Prop) x y,
    starr R x y
    -> star R x y.
Proof.
intros T R x y H.
induct H.

(** refl *)
{
intros x.
apply star_refl.
}

(** step *)
{
intros x y z _ IH Hyz.
eapply star_trans; eauto.
apply star_one; auto.
}
Qed.


Definition compose {T : Type} (R R' : T -> T -> Prop) (x x' : T) : Prop :=
  exists x'', R x x'' /\ R' x'' x'.


(** transitive closure *)
Definition plus {T : Type} (R : T -> T -> Prop) : T -> T -> Prop :=
  compose R (star R).


Definition plusr {T : Type} (R : T -> T -> Prop) : T -> T -> Prop :=
  compose (star R) R.


Inductive plusi {T : Type} (R : T -> T -> Prop) : T -> T -> Prop :=
| plusi_one {x y}
    : R x y
      -> plusi R x y

| plusi_step {x y z}
    : R x y
      -> plusi R y z
      -> plusi R x z.


Inductive plusri {T : Type} (R : T -> T -> Prop) : T -> T -> Prop :=
| plusri_one {x y}
    : R x y
      -> plusri R x y

| plusri_step {x y z}
    : plusri R x y
      -> R y z
      -> plusri R x z.


Lemma plus_star :
  forall (T : Type) (R : T -> T -> Prop) x y,
    plus R x y -> star R x y.
Proof.
intros T R x y H.
destruct H as (z & H1 & H2).
eapply star_step; eauto.
Qed.


Lemma star_plus :
  forall (T : Type) (R : T -> T -> Prop) x y,
    star R x y -> x = y \/ plus R x y.
Proof.
intros T R x y Hxy.
destruct Hxy as [ | x y z Hxy Hyz].
  {
  left; auto.
  }

  {
  right.
  exists y.
  auto.
  }
Qed.
  

Lemma star_neq_plus :
  forall (T : Type) (R : T -> T -> Prop) x y,
    star R x y -> x <> y -> plus R x y.
Proof.
intros T R x y Hstar Hneq.
so (star_plus _#4 Hstar) as [Heq | Hplus]; auto.
destruct Hneq; assumption.
Qed.


Lemma plus_one :
  forall (T : Type) (R : T -> T -> Prop) x y,
    R x y -> plus R x y.
Proof.
intros T R x y H.
exists y.
split; auto.
apply star_refl.
Qed.


Lemma plusr_plus :
  forall (T : Type) (R : T -> T -> Prop) x y,
    plusr R x y -> plus R x y.
Proof.
intros T R x y H.
destruct H as (z & Hxz & Hzy).
invert Hxz.
  {
  intros.
  subst.
  apply plus_one; auto.
  }

  {
  intros w Hxw Hwz.
  exists w.
  split; auto.
  eapply star_trans; eauto.
  apply star_one; auto.
  }
Qed.


Lemma plus_plusr :
  forall (T : Type) (R : T -> T -> Prop) x y,
    plus R x y -> plusr R x y.
Proof.
unfold plus, plusr.
intros T R x y Hxy.
destruct Hxy as (z & Hxz & Hzy).
revert x Hxz.
induct Hzy.

(** refl *)
{
intros y z Hzy.
exists z.
split; auto.
apply star_refl.
}

(** cons *)
{
intros x y z Hxy _ IH w Hwx.
so (IH _ Hxy) as (v & Hxv & Hvz).
exists v.
split; auto.
eapply star_step; eauto.
}
Qed.


Lemma plus_trans :
  forall (T : Type) (R : T -> T -> Prop) x y z,
    plus R x y -> plus R y z -> plus R x z.
Proof.
intros T R x y z Hxy Hyz.
destruct Hxy as (w & Hxw & Hwy).
destruct Hyz as (v & Hyv & Hvz).
exists w.
split; eauto using star_trans, star_step.
Qed.


Lemma plus_transitive :
  forall (T : Type) (R : T -> T -> Prop),
    transitive T (plus R).
Proof.
exact plus_trans.
Qed.


Lemma plus_star_trans :
  forall (T : Type) (R : T -> T -> Prop) x y z,
    plus R x y -> star R y z -> plus R x z.
Proof.
intros T R x y z Hplus Hstar.
destruct Hplus as (w & HR & Hstar').
exists w.
split; eauto using star_trans.
Qed.


Lemma star_plus_trans :
  forall (T : Type) (R : T -> T -> Prop) x y z,
    star R x y -> plus R y z -> plus R x z.
Proof.
intros T R x y z Hxy Hyz.
revert Hyz.
induct Hxy; auto.
intros x y w Hxy _ IH Hyz.
exists y.
split; auto using plus_star.
Qed.


Lemma plus_plusi :
  forall (T : Type) (R : T -> T -> Prop) x y,
    plus R x y -> plusi R x y.
Proof.
intros T R x y Hplus.
so (plus_plusr _#4 Hplus) as (z & Hxz & Hzy).
clear Hplus.
revert Hzy.
induct Hxz; eauto using plusi_one.
intros x w z Hxw _ IH Hzy.
eapply plusi_step; eauto.
Qed.


Lemma plusi_plus :
  forall (T : Type) (R : T -> T -> Prop) x y,
    plusi R x y -> plus R x y.
Proof.
intros T R x y Hxy.
induct Hxy; auto using plus_one.
intros x y z Hxy _ IH.
exists y.
split; auto.
apply plus_star; auto.
Qed.


Lemma plus_plusri :
  forall (T : Type) (R : T -> T -> Prop) x y,
    plus R x y -> plusri R x y.
Proof.
intros T R x y Hxy.
destruct Hxy as (z & Hxz & Hzy).
so (plusri_one _#3 Hxz) as Hxz'.
clear Hxz.
revert Hxz'.
induct Hzy; eauto using plusri_one.
intros w y z Hwy _ IH Hxw.
apply IH.
eapply plusri_step; eauto.
Qed.


Lemma plusri_plus :
  forall (T : Type) (R : T -> T -> Prop) x y,
    plusri R x y -> plus R x y.
Proof.
intros T R x y Hxy.
induct Hxy.

(** one *)
{
apply plus_one; auto.
}

(** step *)
{
intros x y z _ IH Hyz.
eapply plus_trans; eauto using plus_one.
}
Qed.


Lemma plus_step :
  forall (T : Type) (R : T -> T -> Prop) x y z,
    R x y -> plus R y z -> plus R x z.
Proof.
intros.
exists y.
auto using plus_star.
Qed.


Lemma plus_mono :
  forall (T : Type) (R R' : T -> T -> Prop),
    (forall x y, R x y -> R' x y)
    -> forall x y, plus R x y -> plus R' x y.
Proof.
intros T R R' HR x y Hxy.
destruct Hxy as (z & Hxz & Hzy).
exists z; split; eauto using star_mono.
Qed.


Lemma star_map' :
  forall (T : Type) (R : T -> T -> Prop) f,
    (forall x y, R x y -> R (f x) (f y))
    -> forall x y, star R x y -> star R (f x) (f y).
Proof.
intros T R f HR x y Hxy.
induct Hxy.

(** refl *)
{
intros; apply star_refl.
}

(** step *)
{
intros.
eapply star_step; eauto.
}
Qed.


Lemma plus_map' :
  forall (T : Type) (R : T -> T -> Prop) f,
    (forall x y, R x y -> R (f x) (f y))
    -> forall x y, plus R x y -> plus R (f x) (f y).
Proof.
intros T R f HR x y H.
destruct H as (z & H1 & H2).
exists (f z).
split; eauto using star_map'.
Qed.


Lemma star_mono_map :
  forall (T : Type) (R R' : T -> T -> Prop) f,
    (forall x y, R x y -> R' (f x) (f y))
    -> forall x y, star R x y -> star R' (f x) (f y).
Proof.
intros T R R' f HR x y H.
induct H.

(** refl *)
{
intros; apply star_refl.
}

(** step *)
{
intros.
eapply star_step; eauto.
}
Qed.


Lemma plus_mono_map :
  forall (T : Type) (R R' : T -> T -> Prop) f,
    (forall x y, R x y -> R' (f x) (f y))
    -> forall x y, plus R x y -> plus R' (f x) (f y).
Proof.
intros T R R' f HR x y Hxy.
destruct Hxy as (z & Hxz & Hzy).
exists (f z).
split; auto.
eapply star_mono_map; eauto.
Qed.


Lemma plus_idem :
  forall (T : Type) (R : T -> T -> Prop) x y,
    plus R x y <-> plus (plus R) x y.
Proof.
intros T R x y.
split.
  {
  intro Hp.
  apply plus_one; auto.
  }

  {
  intro Hpp.
  so (plus_plusi _#4 Hpp) as Hpp'.
  clear Hpp.
  induct Hpp'; eauto.
  intros x y z Hxy _ Hyz.
  eapply plus_trans; eauto; done.
  }
Qed.


Lemma plus_of_transitive :
  forall (T : Type) (R : T -> T -> Prop),
    transitive T R
    -> forall x y, plus R x y -> R x y.
Proof.
intros T R Htrans x y Hplus.
so (plus_plusi _#4 Hplus) as Hplus'.
induct Hplus'; eauto using Htrans.
Qed.


Lemma plus_well_founded :
  forall (T : Type) (R : T -> T -> Prop),
    well_founded R
    -> well_founded (plus R).
Proof.
intros T R Hwf.
unfold well_founded.
apply (well_founded_ind Hwf (Acc (plus R))).
intros x IH.
apply Acc_intro; [].
intros y Hyx.
remember x as x' eqn:Heq in Hyx.
so (plus_plusi _#4 Hyx) as Hyx'; clear Hyx.
revert Heq.
induct Hyx'.
  {
  intros y x' Hyz ->.
  apply IH; auto.
  }

  {
  intros y z x' Hyz Hxz IH' ->.
  apply (@Acc_inv _ _ z); auto; [].
  apply plus_one; auto.
  }
Qed.


Lemma plus_ind :
  forall (T : Type) (R P : T -> T -> Prop),
    (forall x y z, R x y -> (y = z \/ (plus R y z /\ P y z)) -> P x z)
    -> forall x y, plus R x y -> P x y.
Proof.
intros T R P Hind x y Hxy.
so (plus_plusi _#4 Hxy) as Hxy'; clear Hxy.
induct Hxy'.

(** one *)
{
intros x y Hxy.
apply (Hind x y y); auto.
}

(** step *)
{
intros x y z Hxy Hyz IH.
apply (Hind x y z); auto; [].
right.
auto using plusi_plus.
}
Qed.


Lemma plus_ind_r :
  forall (T : Type) (R P : T -> T -> Prop),
    (forall x y z, (x = y \/ (plus R x y /\ P x y)) -> R y z -> P x z)
    -> forall x y, plus R x y -> P x y.
Proof.
intros T R P Hind x y Hxy.
so (plus_plusri _#4 Hxy) as Hxy'; clear Hxy.
induct Hxy'.

(** one *)
{
intros x y Hxy.
apply (Hind x x y); auto.
}

(** step *)
{
intros x y z Hxy IH Hyz.
apply (Hind x y z); auto; [].
right.
auto using plusri_plus.
}
Qed.


Lemma well_founded_impl_irrefl :
  forall (T : Type) (P : T -> T -> Prop),
    well_founded P
    -> forall x, P x x -> False.
Proof.
intros T P Hwf x Hx.
revert Hx.
wfinduct x using Hwf.
intros x IH Hx.
eapply IH; eauto.
Qed.
