### A Pluto.jl notebook ###
# v0.18.0

using Markdown
using InteractiveUtils

# ╔═╡ 6bfb7efa-414e-4123-be13-704d82b67500
begin
	using UUIDs
	using PlutoUI
	using LightGraphs
	using LightGraphs.SimpleGraphs
	using GraphRecipes
	using AbstractTrees
	using Plots
	using Luxor
	using Kroki

	# patch Base.collect because for inexplicable reasons it is bugged
	function Base.collect(si::Iterators.Stateful)
		items = Vector()
	 	it = iterate(si)
		while it !== nothing
			i, state = it
			push!(items, i)
			it = iterate(si)
		end
		items
	end

	
	function ∘(a::Any, b::Any) b end
	PlutoUI.TableOfContents(title="Table of Contents", indent=true)
end

# ╔═╡ cba2a2a6-aaa5-4988-b954-552b2b700703
@png begin
	sethue("blue")
	rect(Luxor.Point(-10,-25), -200, 50, :stroke)
	sethue("red")
	rect(Luxor.Point(10,-25), 100, 50, :stroke)
	sethue("green")
	setdash("dot")
	rect(Luxor.Point(-60,-10), 100, 20, :stroke)
end 500 100

# ╔═╡ 56582511-0326-4417-9a95-5ff407b438b6
md"""
# A Literate Programming Specification of Biopolymer Composition Constraints

Biopolymers, such as DNA, RNA and proteins are often conceptualised in terms of a sereies of regions or blocks or features.
These may be promoters or genes, binding sites, enzymatic catalytic sites and so on.
When designing these we often wish to specify abstractly the relative positioning of these regions within the biopolymer, but sometimes without giving concrete locations.

An important design constraint in this work is that the concrete locations of the regions being designed is not known, but their relative positioning may be specified or implied by the design constraints.

This notebook outlines a terminology for describing these designs using RDF predicates, and any auxiliary relations required to unambiguously state their semantic interpretation.
For further information see [BBF RFC ?: Formalised terms for biopolymer
composition constraints](not published yet).
Where possible, the specification is given both as text and as executable code.

The various sections of this notebook build up from basic concepts to the more complex design relations.
The trivial or well-known types and relations are given for completeness. Relations will be written infix where possible, to mirror the syntax of RDF.

Equations will be marked with **:norm** to indicate that this is the normalized form, using a more restricted vocabulary.
Equations may also be annotated with **:simp** where concepts can be simplified by rewriting into more fundamental relations, possibly by introducing new existentials.
Lastly, they may be annotated with **:end** where they represent a proposition that resolves to a consistent (⊤) or inconsistent (⊥) state.
The ⇒, ⇔ operators and ⊤, ⊥ values are not part of the constraints terminology.

Some blocks of code end with `∘ nothing` to tidy the pluto notebook rendering, and has no additional purpose or meaning beyond that.
"""

# ╔═╡ ace787f1-6de8-4f4b-b526-d26a2cc4813f
md"""
## Foundational Types and Relations
"""

# ╔═╡ 2a0145f6-6c2e-4342-8b34-c7bc0acdb0b2
md"""
The constraints vocabulary is designed to allow complex and rich constraints between objects to be described.
The objects are referred to as entities, and the constraints as axioms.
The vocabulary as a whole is composed of the types of entities and the axioms available to describe these entities.
"""

# ╔═╡ 0d77a3e7-2570-4d4d-9443-ace9dd7b8504
md"""
### Entities and Variables
Entities represent the things that we wish to talk about.
An entity may be a gene, a place within a chromosome, or even a variable.
"""

# ╔═╡ b9328d7d-1633-4f0a-b812-7cd50937f1d9
begin
	"A thing to talk about."
	abstract type Entity end
end ∘ nothing

# ╔═╡ c8789a4e-89c0-4077-87ae-72cd5b3fd5f2
md"""
Variables are place-holders for entities that are known to exist but may not have been identified.
Two or more variables may refer to the same entity.
It is even possible for variables to never be resolved to concrete entities.
"""

# ╔═╡ 5bbcf948-26a0-428f-bb9e-e4f6fe2aa9b9
begin
	"""
	Variables that represent unknown or unspecified values.
	"""
	struct Var <: Entity id::UUID end
	var()::Var = Var(UUIDs.uuid1())
	var(n) = [Var(UUIDs.uuid1()) for _ in 1:n]
end ∘ nothing

# ╔═╡ b8822080-1530-489e-bc7a-e48f6bd1cc8b
md"""
### Axioms and Relations

Axioms are statements within our vocabularies that say something about one or more entities.
"""

# ╔═╡ 05bdbbe7-d717-4be3-ba04-5fbfdfc89719
begin
	"""Abstract type for all types that represent axioms."""
	abstract type Axiom end
end ∘ nothing

# ╔═╡ 873daf1c-9746-4bde-bbec-186a69d4b224
md"""
Most axioms are two-place relations, of the form *r*($a, b$).
These are common enough that we can provide some special-case handling.
"""

# ╔═╡ 74ffabfb-cfe4-4fe7-85be-2dec1d30a378
begin
	"Two-place relation"
	abstract type Relation <: Axiom end
end ∘ nothing

# ╔═╡ 6cc3c476-149d-4119-8be1-8dc3ac8c0c31
md"""
### Normalization, Simplification and Fundamentals

The vocabulary provided by a set of axioms usually allows the same facts to be expressed in multiple ways.
Often there is a minimal sub-set of axioms that are logically sufficient.
Normalization is the process of rewriting terms into this normalized sub-set.

Simplification is the process of re-writing facts in a vocabulary into more fundamental facts from that and/or other vocabularies.
Simplification rules are defined only for the normalized vocabulary.
Other terms can be simplified by first normalizing.
The simplified form of an axiom is often more verbose, combining multiple simple statements with logical operators.

After all applicable re-writes have been made, the remaining entities and axioms are *fundamental*, meaning that they represent semantics that can not be decomposed further into other entities and axioms.
"""

# ╔═╡ 93b00f2a-7fc7-4a21-8dac-5088279a4569
begin
	"""
	Normalize the representation of an axiom.
	Return nothing if it is already normalized.
	"""
	function norm(ax::Axiom)::Union{Axiom, Nothing}		nothing	end
	
	"""
	Define the axiom in a more fundamental form.
	Indicates that a concept can be simplified by rewriting.
	Return nothing if it can not be simplified.
	"""
	function simp(ax::Axiom)::Union{Axiom, Nothing}		nothing	end

	
	"""Test if an axiom is fundamental.
	By default, all axioms are not fundamental."""
	function fundamental(_::Axiom)::Bool
		false
	end
end ∘ nothing

# ╔═╡ c11df40f-f7ba-42f4-9d67-56e86b1ce409
md"""
### Logical operators

Basic disjunction/conjunction (or/and) operators allow other axioms to be combined in rich ways.
They are not fundamental, as they are eliminated during reasoning.
"""

# ╔═╡ 4b35aef8-4c21-4202-a186-a5addc44d2a3
begin
	"The foundational logical operators"
	abstract type Junction <: Axiom end
		
	"""Logical disjunction"""
	struct (∨) <: Junction
		axioms::Vector{Axiom}
		function (∨)(as...) new([as...]) end
	end
	
	"""Logical conjunction"""
	struct (∧) <: Junction
		axioms::Vector{Axiom}
		function (∧)(as...) new([as...]) end
	end
end ∘ nothing

# ╔═╡ 8e2709c9-821e-4a33-b638-f4c0e58fd235
md"""
### Equivalency and conflicts.

Equivalency is defined in terms of substitutability within expressions.
Two entities are equivalent if one can replace the other in any expression without altering the truth of that expression.
Both equivalence and non-equivalence are fundamental.

|Term|Definition|
|:---|:---------|
| $a ≃ b$ | The values a and b are equivalent. |
| $a ≄ b$ | The values a and b are not equivalent.|

Exactly one of equivalent and not equivalent hold for any pair of values.

```math
\begin{align}
a ≃ b \vee a ≄ b & \Rightarrow \top, & \text{:end} \\
a ≃ b \wedge a ≄ b & \Rightarrow \bot. & \text{:end}
\end{align}
```
"""

# ╔═╡ 37157b08-cacf-4a36-b8e6-a84dce79af96
begin
	"All relations that model equivalency relationships."
	abstract type Equivalency <: Relation end
	
   "The same value. The ≃ (\\simeq) symbol is chosen to avoid clashes with builtins."
	struct (≃) <: Equivalency 	a; b	end
	"Different values. The ≄ (\\nsime) is chosen to avoid classes with builtins."
	struct (≄) 	<: Equivalency	a; b	end

	fundamental(_::≃) = true
	fumdamental(_::≄) = true
end ∘ nothing

# ╔═╡ 737c8c5f-3606-43cd-bf52-5553c3504df1
md"""
## Constraints Vocabularies

The following sections introduce the various entities and axioms that make up the biopolymer constraints vocabularies, together with their normalization and simplification rules.
These are given both as text/equations and as equivalent executable code specifications.
"""

# ╔═╡ effb7b3e-c129-4a01-a33b-b325d1ffeadb
md"""
### Points

Points are fundamental entities that represent discrete places within a biopolymer.
This specification is silent on if numerically identified places within biopolymers count from 0 or 1.
It is also silent on any choice of representation.

For our implementation, points are associated with arbitrary precision signed integers.
"""

# ╔═╡ 882b9fce-9572-477b-928b-2f7faa383f35
begin
	"A defined place within a biopolymer."
	struct PointRep <: Entity
		at::BigInt
	end

	"A point is either a place or a variable referring to that place."
	const Point = Union{PointRep, Var}

end ∘ nothing

# ╔═╡ 18fc0c3b-8d43-4e23-aee8-b0b87566520a
md"""

### Point Ordering
Points are well-ordered from left to right.
We define relations that capture all of the possible pair-wise constraints on the relative position of two points.
Of these, the < relation is fundamental.
Variables $p$ and $q$ will range over points.

| Term | Definition |
|:-----|:-----------|
|$p < q$ | Point $p$ is to the left of $q$. |
|$p \le q$ | Point $p$ is to the left of, or at the same place as $q$. |
|$p ≃ q$ | Points $p$ and $q$ are at the same place.|
|$p \ge q$ | Point $p$ is at the same place as, or to the right of $q$. |
|$p > q$ | Point $p$ is to the right of $q$.|
|$p ≄ q$ | Points $p$ and $q$ are at different places.|
"""

# ╔═╡ 9d5bb38c-481c-43e2-b671-63330af82f79
begin
	"Point relative ordering relation"
	abstract type PointOrdering <: Relation end

	"To the left of."
	struct (<) 	<: PointOrdering 	p::Point; q::Point	end
	"To the left of or at."
	struct (≤) 	<: PointOrdering 	p::Point; q::Point	end
	"To the right of or at the same place."
	struct (≥) 	<: PointOrdering 	p::Point; q::Point	end
	"To the right of."
	struct (>) 	<: PointOrdering 	p::Point; q::Point  end

	fundamental(_::<) = true
end ∘ nothing

# ╔═╡ 1d819b3f-eba6-47ce-bf80-a18fb667ddfd
md"""
The normalized forms of point location axioms are expressed in the left-to-right order.

```math
\begin{align}
q > p & \Leftrightarrow p < q, & \text{:norm} \\
q \ge p & \Leftrightarrow p \le q. & \text{:norm}
\end{align}
```
"""

# ╔═╡ 0e0ad0d6-2f67-45a5-9f68-2ebe428813db
begin
	norm(gt::(>))::(<) = <(gt.p, gt.q)
	norm(ge::(≥))::(≤) = ≤(ge.p, ge.q)
end ∘ nothing

# ╔═╡ 86744569-a16c-46ea-ac5f-7749e1ee1397
md"""
The ≤ relation can be further simplified by 
```math
\begin{align}
p \le q & \Leftrightarrow p < q \lor p = q. & \text{:simp}
\end{align}
```
"""

# ╔═╡ 2a7cae23-aa3a-425b-be97-e16565bba189
begin
	simp(le::(≤)) = (le.p < le.q) ∨ (le.p ≃ le.q)
end ∘ nothing

# ╔═╡ 7a888d5d-44df-45e0-b2b3-3922dbdecf93
md"""
The < operator is tranistive.
A point can not be both to the left and to the right of another point.

```math
\begin{align}
p<q \wedge q<r & \Rightarrow p<r, &\text{(transitive)}\\
p<q \wedge q<p & \Rightarrow \bot. & \text{:end}
\end{align}
```
"""

# ╔═╡ 289ad30b-056f-46fd-877c-6fb20db81749
md"""
### Known Point Spacings
It is convenient to introduce a fundamental gapsize relation, for situations where exact distance between two points matters.
Gapsize states exactly how many unique points can fit between two points.
Gapsize does not imply a relative ordering of the points.
Touches is the special-case where the two points are distinct but no other points lie between them.
We shall use the variable $?n \in \mathbb N$ for natural numbers.

| Term | Definition |
|:-----|:-----------|
|*gapsize*$(p, q, n)$| The number of distinct points lying between $p$ and $q$.|
|$p$ *touches* $q$| The two points touch one-another.|
|$p$ *does\_not\_touch* $q$| The two points do not touch one-another.|
"""

# ╔═╡ 433d2722-a463-490f-a053-80544b7d6500
begin
	"Positive integer"
	const PosInt = Union{Unsigned, Var}
	
	abstract type PointNeighbours <: Relation end
	
	struct gapsize  		<: Axiom			a::Point; b::Point; d::PosInt end
	struct touches 			<: PointNeighbours	a::Point; b::Point end
	struct does_not_touch 	<: PointNeighbours	a::Point; b::Point end

	fundamental(_::gapsize) = true
end ∘ nothing

# ╔═╡ 8f678910-0c5d-4dee-bc43-261f071429c8
md"""
```math
\begin{align}
touches(p, q) & \Leftrightarrow gapsize(p, q, 0) & \text{:norm},\\
does\_not\_touch(p, q) & \Leftrightarrow gapsize(p, q, n:n>0) & \text{:norm}.
\end{align}
```
"""

# ╔═╡ 1492766f-6d10-418d-a41e-d97920adf56c
begin
	norm(t::touches)::gapsize = gapsize(t::p, t::q, 0)
	norm(t::does_not_touch) = begin
		n = var()
		gapsize(t.p, t.q, n) ∧ n > 0
	end
end ∘ nothing

# ╔═╡ 337b4b86-9a9d-4546-854a-ab934381ad1a
md"""
### Strands

Locations within DNA and RNA biopolymers are often described in terms of top and bottom strands.
Strandedness indicates which of the strands an entity is associated with.
There are many potentially types of stranded entities, including but not limited to stranded positions and stranded intervals.

|Term|Definition|
|:---|:---------|
|$x$ *strand* $\{Top,Bottom\}$| The entity $x$ is on the specified strand.|

The top and bottom values for strands are always non-equal.

```math
\begin{align}
Top = Bottom & \Rightarrow \bot & \text{:end}
\end{align}
```
"""

# ╔═╡ db200cf8-8d7a-4fa1-9e3a-e86b019d54ef
begin
	struct StrandRep <: Entity name::String end
	const TOP_STRAND = StrandRep("TOP_STRAND")
	const BOTTOM_STRAND = StrandRep("BOTTOM_STRAND")
	const Strand = Union{StrandRep, Var}

	struct strand <: Relation a::Entity; s::Strand end
end

# ╔═╡ 019c256c-516a-44ce-ae0e-ce852699a0aa
md"""
### Stranded Positioning

It is convenient to introduce relations over stranded points.
These represent ordering relative to that strand.
The letter $s$ will be used to refer to the strand that defines the ordering direction.
Points that are $\stackrel{Top}<$ will be $\stackrel{Bottom}>$, as the ordering is strand-sensitive.

|Term|Definition|
|:---|:---------|
|$a \stackrel{s}< b$|The position $a$ is leftwards of $b$ relative to strand $s$.|
|$a \stackrel{s}\le b$|The position $a$ is not rightwards of $b$ relative to strand $s$.|
|$a \stackrel{s}\ge b$|The position $a$ is not leftwards of $b$ relative to strand $s$.|
|$a \stackrel{s}> b$|The position $a$ is rightwards of $b$ relative to strand $s$.|

"""

# ╔═╡ 0e2180ad-fbf5-47d8-afc8-386e7f070e48
begin
	abstract type StrandedOrdering <: Axiom end
	
	struct (<ˢ) <: StrandedOrdering  p::Point; q::Point; s::Strand end
	struct (≤ˢ) <: StrandedOrdering  p::Point; q::Point; s::Strand end
	struct (≥ˢ) <: StrandedOrdering  p::Point; q::Point; s::Strand end
	struct (>ˢ) <: StrandedOrdering  p::Point; q::Point; s::Strand end
end ∘ nothing

# ╔═╡ ae749f60-95dc-4f15-9958-a56c058af938
md"""
As for the basic ordering relations over points, $\stackrel{s}<$ and $\stackrel{s}\leq$ relations are preferred, regardless of the strand.

```math
\begin{align}
a \stackrel{s}> b & \Leftrightarrow b \stackrel{s}< a, & \text{:norm}\\
a \stackrel{s}\ge b & \Leftrightarrow b \stackrel{s}\le a. & \text{:norm}
\end{align}
```
"""

# ╔═╡ 0ae56b35-1568-4585-9f24-64633c100b3d
begin
	norm(r::>ˢ)::<ˢ = r::b <ˢ r::a
	norm(r::≥ˢ)::≤ˢ = r::b ≤ˢ r::a
end ∘ nothing

# ╔═╡ 7e942344-cc0e-4c4e-8ddc-a562804bd358
md"""
The stranded pointwise relations can be interpreted in terms of strand and the underlying relations. All stranded relations on the top strand reduce to the corresponding unstranded relation. All stranded relations on the bottom strand reduce to the inverse relation. This allows us to derive the simp rules.

```math
\begin{align}
a \stackrel{Top}< b & \Leftrightarrow a < b, & \text{:simp}\\
a \stackrel{Bottom}< b & \Leftrightarrow a > b, & \text{:simp}\\
a \stackrel{Top}≤ b & \Leftrightarrow a ≤ b, & \text{:simp}\\
a \stackrel{Bottom}≤ b & \Leftrightarrow a ≥ b, & \text{:simp}\\
\end{align}

```
"""

# ╔═╡ aee4e6ff-9dea-4213-b171-535aa0439bb0
begin
	simp(r::<ˢ) =
		(r::s == Top ∧ r.a < r.b) ∨ (r::s == Bottom ∧ r.a > r.b)
	simp(r::≤ˢ) =
		(r::s == Top ∧ r.a ≤ r.b) ∨ (r::s == Bottom ∧ r.a ≥ r.b)
	simp(r::≥ˢ) = 
		(r::s == Top ∧ r.a ≥ r.b) ∨ (r::s == Bottom ∧ r.a ≤ r.b)
	simp(r::>ˢ) =
		(r::s == Top ∧ r.a > r.b) ∨ (r::s == Bottom ∧ r.a < r.b)
end ∘ nothing

# ╔═╡ b08e3688-0b1b-422c-b383-53dad7115c5d
md"""
### Intervals

The fundamental unit of biosequence design is the interval. It identifies a segment of the biosequence.

We define intervals over points, by the points that they contain. The left-most contained point and the right-most contained point demarcate the extent of an interval. It follows from this that intervals may not be empty. Intervals will be referred to using the variables $?a$ and $?b$.

| Term | Definition |
|:-----|:-----------|
|$a$ *containing* $p$| The interval $a$ contains $p$. |
|$a$ *left* $p$ | The left-most point in the interval $a$ is $p$. |
|$a$ *right* $p$| The right-most point in the interval $a$ is $p$. |

The left/right points and all contained points are well-ordered:

```math
\begin{align}
left(a, l), right(a, r) & \Rightarrow l \le r & \text{:rep}
\end{align}
```
```math
\begin{align}
\forall q. containing(a, q) & : & left(a, p) & \wedge p \le q, \\
&& right(a, p) & \wedge p \ge q.
\end{align}
```
"""

# ╔═╡ 8b3217c0-860d-413c-b80d-613c14136535
begin
	abstract type IntervalRep <: Entity end
	const Interval = Union{IntervalRep, Var}
	
	abstract type IntervalPointRelation <: Relation end
	
	"A point is contained within an interval"
	struct containing 	<: IntervalPointRelation 	a::Interval; p::Point end
	
	"The left-most point contained by an interval"
	struct left 		<: IntervalPointRelation	a::Interval; p::Point end
	
	"The right-most point contained by an interval"
	struct right 		<: IntervalPointRelation	a::Interval; p::Point end
end ∘ nothing

# ╔═╡ 38747f55-51e7-42f3-89db-f53f23b4c608
begin
	rep(a::Interval) = begin
		l, r = var(2)
		∧(left(i, l), right(i, r), l < r)
	end
end ∘ nothing

# ╔═╡ 906d8176-7eaf-4803-b8f7-a6c3329877e5
md"""
### Length Relations

In addition to point-wise relations on intervals, it is also necessary to work with lengths.

| Term | Definition |
|:-----|:-----------|
|$a$ *interval_length* $n$| The length of the interval, inclusive of all points from *left* to *right*.|

The $length$ of an interval is exactly two larger than the gapsize between $left$ and $right$.
Equivlalently, it is the size of the cooresponding $contains$ set.

```math
\begin{align}
interval\_length(a, n+2) & \Leftrightarrow left(a, p), right(a, q), gapsize(p, q, n) \\
interval\_length(a, n) & \Leftrightarrow |S|, \{s \in S | containing(a, s)\} \\
\end{align}
```
"""

# ╔═╡ 177e8e8d-0607-40d2-b1ac-56c53371c2dc
begin
	"The length of an interval"
	struct interval_length <: Relation 	a::Interval; n::Integer end
end ∘ nothing

# ╔═╡ af93e7a0-f3e7-4382-b955-a60b9eba9f78
md"""
It is sometimes useful to assert relative lengths on intervals.
These are equivalent to comparing the the lengths of the two intervals.

| term | definition |
|:-----|:-----------|
|$a$ *shorter\_than* $b$| The interval $a$ is shorter than $b$.|
|$a$ *not\_longer\_than* $b$| The intervall $a$ is shorter than or the same length as $b$.|
|$a$ *same\_length\_as* $b$| The intervals $a$ and $b$ are the same length.|
|$a$ *not\_shorter\_than* $b$| The interval $a$ is the same length or longer than $b$.|
|$a$ *longer\_than* $b$| The interval $a$ is longer than $b$.|
"""

# ╔═╡ 5c4e8e12-12bf-4164-abd5-f4ac7a8b9aeb
begin
	abstract type IntervelLengths <: Relation
		
	"One interval is shorter than another."
	struct shorter_than 	<: IntervelLengths 	a::Interval; b::Interval end
	
	"One interval is shorter or the same length as another."
	struct not_longer_than	<: IntervelLengths 	a::Interval; b::Interval end
	
	"Two intervals have the same length."
	struct same_length_as	<: IntervelLengths 	a::Interval; b::Interval end
	
	"One interval is longer or the same length as another."
	struct not_shorter_than	<: IntervelLengths 	a::Interval; b::Interval end
	
	"One interval is longer than another."
	struct longer_than		<: IntervelLengths 	a::Interval; b::Interval end
end ∘ nothing

# ╔═╡ 97c16ebc-2bd3-4d8b-bb37-25e3e74e4dec
md"""
The obvious equivalences and their associated normalization rules apply.

```math
\begin{align}
not\_shorter\_than(a, b) & \Leftrightarrow not\_longer\_than(b, a), &\text{:norm} \\
longer\_than(a, b) & \Leftrightarrow shorter\_than(b, a). &\text{:norm}
\end{align}
```
"""

# ╔═╡ 1d713b63-eba5-4cc3-9746-75002b46af72
begin
	norm(nst::not_shorter_than)::not_longer_than = not_longer_than(nst.b, nst.a)
	norm(lt::longer_than)::shorter_than = shorter_than(lt.b, lt.a)
end ∘ nothing

# ╔═╡ 9764ca42-2da7-4751-9d5d-cf96b54031f1
md"""
Given ``length(a, l_a)``, ``length(b, l_b)``:

```math
\begin{align}
shorter\_than(a, b) & \Leftrightarrow l_a < l_b, & \text{:simp} \\
not\_longer\_than(a, b) & \Leftrightarrow l_a \le l_b, & \text{:simp} \\
same\_length\_as(a, b) & \Leftrightarrow l_a = l_b, & \text{:simp} \\
not\_shorter\_than(a, b) & \Leftrightarrow l_a \ge l_b, & \text{:simp} \\
longer\_than(a, b) & \Leftrightarrow l_a > l_b. & \text{:simp}
\end{align}
```
"""

# ╔═╡ 4fbcf38d-7065-4fbe-b5e8-ead0bc126b1f
begin
	simp(r::shorter_than) = begin
		l_a, l_b = new_atom(2)
		∧(interval_length(r.a, l_a), interval_length(r.b, l_b), l_a < l_b)
	end
	simp(r::not_longer_than) = begin
		l_a, l_b = new_atom(2)
		∧(interval_length(r.a, l_a), interval_length(r.b, l_b), l_a ≤ l_b)
	end
	simp(r::same_length_as) = begin
		l_a, l_b = new_atom(2)
		∧(interval_length(r.a, l_a), interval_length(r.b, l_b), l_a == l_b)
	end
	simp(r::not_shorter_than) = begin
		l_a, l_b = new_atom(2)
		∧(interval_length(r.a, l_a), interval_length(r.b, l_b), l_a ≥ l_b)
	end
	simp(r::longer_than) = begin
		l_a, l_b = new_atom(2)
		∧(interval_length(r.a, l_a), interval_length(r.b, l_b), l_a > l_b)
	end

end ∘ nothing

# ╔═╡ 6734c935-d5b0-41b3-8ead-20299df899e8
md"""
### Interval Topological Relations.

The potential relationships between intervals are quite rich. Choosing words that clearly convey each and every one is difficult. All are defined in terms of one or both ends of the two intervals.

|Term|Definition|
|:---|:---------|
|$a$ *same_location* $b$| The two intervals have identical left/right points.|
|$a$ *contains* $b$| Interval $a$ contains or is identical to location $b$.|
|$a$ *contained_by* $b$| Interval $a$ is contained by or identical to location $b$.|
|$a$ *within* $b$| Interval $a$ contains and is not identical to location $b$.|
|$a$ *starts_with* $b$| Interval $a$ contains $b$ and they share their left.|
|$a$ *ends_with* $b$| Interval $a$ contains $b$ and they share their right.|
|$a$ *start_of* $b$| Interval $a$ is contained by $b$ and they share their left.|
|$a$ *end_of* $b$| Interval $a$ is contained by $b$ and they share their right.|
|$a$ *then* $b$| The right of interval $a$ touches but doesn't overlap the left of $b$.|
|$a$ *before* $b$| Interval $a$ is entirely to the left of $b$.|
|$a$ *after* $b$| Interval $a$ is entirely to the right of $b$.|
|$a$ *gap_then* $b$| Interval $a$ is followed by a non-empty gap and then by $b$.|
|$a$ *overlaps_with* $b$| The two intervals overlap by at least one position.|
|$a$ *does\_not_overlap* $b$| The two intervals do not overlap.|
"""

# ╔═╡ 5ca3d707-5a34-4834-8709-b429b620d290
begin
	abstract type IntervalTopology <: Relation end
	
	"The intervals are the same."
	struct same_location	<: IntervalTopology	a::Interval; b::Interval end
	
	"The first intervals contains the second."
	struct contains			<: IntervalTopology	a::Interval; b::Interval end

	"The first interval is within the second."
	struct contained_by		<: IntervalTopology	a::Interval; b::Interval end

	"The first interval strictly contains the second."
	struct within			<: IntervalTopology	a::Interval; b::Interval end
	
	"The two intervals start at the same place but the first one extends further."
	struct starts_with		<: IntervalTopology	a::Interval; b::Interval end
	
	"The two intervals start at the same place but the second one extends further."
	struct start_of			<: IntervalTopology	a::Interval; b::Interval end
	
	"The two intervals end at the same place but the first one extends further."
	struct ends_with		<: IntervalTopology	a::Interval; b::Interval end
	
	"The two intervals end at the same place but the second one extends further."
	struct end_of			<: IntervalTopology	a::Interval; b::Interval end
	
	"The second interval begins immediately after the end of the first."
	struct then				<: IntervalTopology	a::Interval; b::Interval end
	
	"The first interval is entirely before the second."
	struct before			<: IntervalTopology	a::Interval; b::Interval end
	
	"The first interval is entirly after the second."
	struct after			<: IntervalTopology	a::Interval; b::Interval end
	
	"After the first interval ends, there is a gap before the second interval begins."
	struct gap_then			<: IntervalTopology	a::Interval; b::Interval end
	
	"The intervals overlap by at least one position."
	struct overlaps_with	<: IntervalTopology	a::Interval; b::Interval end
	
	"The intervals do not overlap."
	struct does_not_overlap <: IntervalTopology	a::Interval; b::Interval end
end ∘ nothing

# ╔═╡ 42bc8e51-2296-4a18-9c00-934043877db6
md"""
```math
\begin{align}
within(a, b) & \Leftrightarrow contained\_by(b, a), & \text{:norm}\\
after(a, b & \Leftrightarrow before(b, a), & \text{:norm}\\
start\_of(a, b) & \Leftrightarrow starts\_with(b, a), & \text{:norm}\\
end\_of(a, b) & \Leftrightarrow ends_with(b, a), & \text{:norm}\\
after(a, b) & \Leftrightarrow before(b, a), & \text{:norm}\\
does\_not\_overlap(a, b) & \Leftrightarrow before(a, b) \vee after(a, b). & \text{:norm}
\end{align}
```
"""

# ╔═╡ 29f8d68a-5407-4cdd-ae20-64f7baf83c30
begin
	norm(r::within) 			= containe_by(r.b, r.a)
	norm(r::after) 				= before(r.b, r.a)
	norm(r::start_of) 			= starts_with(r.b, r.a)
	norm(r::after)				= before(r.b, r.a)
	norm(r::does_not_overlap)	= before(r.a, r.b) ∨ after(r.a, r.b)
end ∘ nothing

# ╔═╡ 6400ab80-cb5f-47a4-ab97-474827a2e167
md"""
In the following simplifiaction rules, $l_a$, $r_a$, $l_b$ and $r_b$ refer to the left and right ends of intervals $a$ and $b$ respectively.
```math
\begin{align}
same\_location(a, b) & \Leftrightarrow l_a = l_b \wedge r_a = r_b, & \text{:simp}\\
contains(a, b) & \Leftrightarrow l_a \le l_b \wedge r_a \ge r_b, & \text{:simp}\\
contained\_by(a, b) & \Leftrightarrow l_a \ge l_b \wedge r_a \le r_b, & \text{:simp}\\
within(a, b) & \Leftrightarrow l_a < l_b \wedge r_a > r_b, & \text{:simp}\\
starts\_with(a, b) & \Leftrightarrow l_a = l_b \wedge r_a \ge r_b, & \text{:simp}\\
start\_of(a, b) & \Leftrightarrow l_a = l_b \wedge r_a \le r_b, & \text{:simp}\\
ends\_with(a, b) & \Leftrightarrow l_a \le l_b \wedge r_a = r_b, & \text{:simp}\\
end\_of(a, b) & \Leftrightarrow l_a \ge l_b \wedge r_a = r_b, & \text{:simp}\\
then(a, b) & \Leftrightarrow r_a < l_b \wedge touches(r_a, l_b), & \text{:simp}\\
before(a, b) & \Leftrightarrow r_a < l_b, & \text{:simp}\\
after(a, b) & \Leftrightarrow l_a > r_b, & \text{:simp}\\
gap\_then(a, b) & \Leftrightarrow r_a < l_b \wedge does\_not\_touch(r_a, l_b), & \text{:simp}\\
overlaps\_with(a, b) & \Leftrightarrow r_a \ge l_b \wedge l_a \le r_b, & \text{:simp}\\
does\_not\_overlap(a, b) & \Leftrightarrow r_a < l_b \vee l_a > r_b. & \text{:simp}\\
\end{align}
```
"""

# ╔═╡ 82853951-f0b0-4706-a1d6-5f1bd285d573
begin
	simp(r::same_location) = begin 
		lᵃ, lᵇ, rᵃ, rᵇ = var(4)
		∧(left(r.a, lᵃ), left(r.b, lᵇ), right(r.a, rᵃ), right(r.b, rᵇ),
			lᵃ ≃ lᵇ, rᵃ ≃ rᵇ)
	end
	
	simp(r::contains) = begin
		lᵃ, lᵇ, rᵃ, rᵇ = var(4)
		∧(left(r.a, lᵃ), left(r.b, lᵇ), right(r.a, rᵃ), right(r.b, rᵇ),
			lᵃ ≤ lᵇ, rᵃ ≥ rᵇ)
	end
	
	simp(r::contained_by) = begin
		lᵃ, lᵇ, rᵃ, rᵇ = var(4)
		∧(left(r.a, lᵃ), left(r.b, lᵇ), right(r.a, rᵃ), right(r.b, rᵇ),
			lᵃ ≥ lᵇ, rᵃ ≤ rᵇ)
	end
	
	simp(r::within) = begin
		lᵃ, lᵇ, rᵃ, rᵇ = var(4)
		∧(left(r.a, lᵃ), left(r.b, lᵇ), right(r.a, rᵃ), right(r.b, rᵇ),
			lᵃ < lᵇ, rᵃ > rᵇ)
	end
	
	simp(r::starts_with) = begin
		lᵃ, lᵇ, rᵃ, rᵇ = var(4)
		∧(left(r.a, lᵃ), left(r.b, lᵇ), right(r.a, rᵃ), right(r.b, rᵇ),
			lᵃ ≃ lᵇ, rᵃ ≥ rᵇ)
	end
	
	simp(r::start_of) = begin
		lᵃ, lᵇ, rᵃ, rᵇ = var(4)
		∧(left(r.a, lᵃ), left(r.b, lᵇ), right(r.a, rᵃ), right(r.b, rᵇ),
			lᵃ ≃ lᵇ, rᵃ ≤ rᵇ)
	end
	
	simp(r::ends_with) = begin
		lᵃ, lᵇ, rᵃ, rᵇ = var(4)
		∧(left(r.a, lᵃ), left(r.b, lᵇ), right(r.a, rᵃ), right(r.b, rᵇ),
			lᵃ ≤ lᵇ, rᵃ ≃ rᵇ)
	end
	
	simp(r::end_of) = begin
		lᵃ, lᵇ, rᵃ, rᵇ = var(4)
		∧(left(r.a, lᵃ), left(r.b, lᵇ), right(r.a, rᵃ), right(r.b, rᵇ),
			lᵃ ≥ lᵇ, rᵃ ≃ rᵇ)
	end
	
	simp(r::then) = begin
		lᵃ, lᵇ, rᵃ = var(3)
		∧(left(r.a, lᵃ), left(r.b, lᵇ), right(r.a, rᵃ),
			lᵃ < lᵇ, touches(rᵃ, lᵇ))
	end
	
	simp(r::before) = begin
		lᵇ, rᵃ = var(2)
		∧(left(r.b, lᵇ), right(r.a, rᵃ),
			rᵃ < lᵇ)
	end
	
	simp(r::after) = begin
		lᵃ, rᵇ = var(2)
		∧(left(r.a, lᵃ), right(r.b, rᵇ),
			lᵃ > rᵇ)
	end
	
	simp(r::gap_then) = begin
		lᵇ, rᵃ = var(2)
		∧(left(r.b, lᵇ), right(r.a, rᵃ),
			rᵃ > lᵇ, does_not_touch(rᵃ, lᵇ))
	end
	
	simp(r::overlaps_with) = begin
		lᵃ, lᵇ, rᵃ, rᵇ = var(4)
		∧(left(r.a, lᵃ), left(r.b, lᵇ), right(r.a, rᵃ), right(r.b, rᵇ),
			rᵃ ≥ lᵇ, lᵃ ≤ rᵇ)
	end
	
	simp(r::does_not_overlap) = begin
		lᵃ, lᵇ, rᵃ, rᵇ = var(4)
		∧(left(r.a, lᵃ), left(r.b, lᵇ), right(r.a, rᵃ), right(r.b, rᵇ),
			lᵃ < lᵇ, rᵃ > rᵇ)
	end
	
	
end ∘ nothing

# ╔═╡ e663675d-f69a-4a1e-a0a1-380287d32fd8
md"""
### Stranded Intervals

Locations within DNA and RNA biopolymers are often described in terms of top and bottom strands. Stranded intervals are associated with exacty one strand.

|Term|Definition|
|:---|:---------|
|$a$ *strand* ${Top,Bottom}$| The stranded interval $a$ is on the specified strand.|

This re-uses the $strand$ relation defined earlier.
"""


# ╔═╡ 3a4a726b-2cb1-4510-97db-76f4be50809a
begin
	abstract type StrandedIntervalRep <: IntervalRep end
	const StrandedInterval = Union{StrandedIntervalRep, Var}
end ∘ nothing

# ╔═╡ a207ec7f-32c8-4263-9a33-b49ca957f80c
md"""
### Relative Strand Relations

As the two strands of DNA or RNA are anti-parallel, intervals that point "rightwards" on the top strand will point "leftwards" on the bottom. This gives rise to the idea of a stranded interval's 5' and 3' ends.

|Term|Definition|
|:---|:---------|
|$a$ *five_prime* $p$| The 5' end of the stranded interval $a$ is $p$.|
|$a$ *three_prime* $p$| The 3' end of the stranded interval $a$ is $p$.|
"""

# ╔═╡ a1a85b07-3afa-4bb5-971a-645073f3a208
begin
	abstract type StrandedPointRelation <: Relation end
	
	struct five_prime 	<: StrandedPointRelation a::StrandedInterval; p::Point  end
	struct three_prime 	<: StrandedPointRelation a::StrandedInterval; p::Point  end
end ∘ nothing

# ╔═╡ 721082c5-5eff-41e9-b199-7af5ec890e3b
md"""
For stranded intervals on the top strand, the 5' and 3' ends will match the left and right ends. For those on the bottom strand, they are reversed.

```math
\begin{align}
five\_prime(a, p) & \Leftrightarrow & strand(a, Top) & \wedge left(a, p) &\\
& \vee & strand(a, Bottom) & \wedge right(a, p), & \text{:simp} \\
three\_prime(a, p) & \Leftrightarrow & strand(a, Top) & \wedge right(a, p) &\\
& \vee & strand(a, Bottom) & \wedge left(a, p). & \text{:simp}

\end{align}
```

It follows from this that:

```math
\begin{align}
strand(a, Top) & \land five\_prime(a, l) \land three\_prime(a, r) & \Rightarrow l \le r, \\
strand(a, Bottom) & \land five\_prime(a, l) \land three\_prime(a, r) & \Rightarrow l \ge r.
\end{align}
```
"""

# ╔═╡ db4eb41d-6751-46d2-9e44-e7dc1c892b4d
begin
	simp(r::five_prime) =
		(strand(r.i, Top) ∧ left(r.i, r.p)) ∨
		(strand(r.i, Bottom) ∧ right(r.i, r.p))
	simp(r::three_prime) =
		(strand(r.i, Top) ∧ right(r.i, r.p)) ∨
		(strand(r.i, Bottom) ∧ left(r.i, r.p))
end ∘ nothing

# ╔═╡ 4238943b-9659-4fe9-b6ca-d94018b0b856
md"""
Stranded intervals may be on the same strand or on different strands.

|Term|Definition|
|:---|:---------|
|$a$ *same_strand* $b$| The stranded intervals $a$ and $b$ are on the same strand."
|$a$ *different_strand* $b$| The stranded intervals $a" and $b$ are on different strands.|
"""

# ╔═╡ fbc1dc24-a493-48a1-ad5f-421b1b777cf1
begin
	abstract type RelativeStrand <: Relation end
	struct same_strand 		<: RelativeStrand a::StrandedInterval; b::StrandedInterval end
	struct different_strand <: RelativeStrand a::StrandedInterval; b::StrandedInterval end
end ∘ nothing

# ╔═╡ 53a07edc-b072-4cfb-9ae3-e90382b90be8
md"""

Given ``strand(a, s^a)`` and ``strand(b, s^b)``:

```math
\begin{align}
same\_strand(a, b) & \Leftrightarrow s^a = s^b, & \text{:simp}\\ 
different\_strand(a, b) & \Leftrightarrow s^a \ne s^b. & \text{:simp}
\end{align}
```
"""

# ╔═╡ 4b0dfcba-8435-4a60-9bca-bbc4f8cf1a54
begin
	simp(r::same_strand) = begin
		s = var()
		∧(strand(r.a, s), strand(r.b, s))
	end
	simp(r::different_strand) = begin
		s_a, s_b = new_atom()
		∧(strand(r.a, s_a), strand(r.b, s_b), s_a ≄ s_b)
	end
end ∘ nothing

# ╔═╡ a8e82de2-eedb-46ac-bf24-289d3ea32df1
md"""
### Stranded Topological Relations.

The complexities of naming stranded relations are compounded since we need terms for various interactions between intervals on various strands.
Some relations apply to both stranded and unstranded intervals unchanged. For example, $contained$ will apply exactly identically regarless of the strandedness of the intervals. However, $touches$, for example, requires clarification as in an abstract design where the strandedness of two intervals is unknown, it is important to specify which ends are infact touching. We have identified a minimal set of base relations, which are then indexed by the interacting ends of the intervals.
"""

# ╔═╡ 6432fe70-1789-4609-bd25-ea4984932981
md"""
The first relations position one interval relative to the strand of the other.

|Term|Definition|
|:---|:---------|
|$a$ *upstream\_of* $b$| Stranded interval $?a$ is to the 5' side of $b$.|
|$a$ downstream\_of $b$| Stranded interval $?a$ is to the 3' side of $b$.|
"""

# ╔═╡ c870418e-307f-44bf-ab8d-9efdf6161a4f
begin
	abstract type StrandedTopology <: Relation end
	struct upstream_of 	 <: StrandedTopology 	a::Interval; b::StrandedInterval end
	struct downstream_of <: StrandedTopology 	a::Interval; b::StrandedInterval end
end

# ╔═╡ 8501b399-a74d-4e4c-954a-a556353b9847
md"""
We shall use $l^a$, $l^b$, $r^a$, $r^b$, $s^a$, $s^b$, $a^{5'}$, $b^{5'}$, $a^{3'}$ and $b^{3'}$ represent the ends, strands and stranded ends of the ranges.
The terms can be defined as follows:

```math
\begin{align}
upstream\_of(a, b) & \Leftrightarrow l^a \stackrel{s_b}< b^{5'} \wedge r^a \stackrel{s_b}< b^{5'}, & \text{:simp}\\
downstream\_of(a, b) & \Leftrightarrow l^a \stackrel{s_b}> b^{3'} \wedge r^a \stackrel{s_b}> 3'_b. & \text{:simp}
\end{align}
```
"""

# ╔═╡ 9054b61c-ae11-4c17-9811-445cd96e034a
begin
	simp(r::upstream_of) = begin
		sᵇ, lᵃ, rᵃ, b⁵′ = var(4)
		∧(left(r.a, lᵃ), right(r.a, rᵃ), strand(r.b, sᵇ), five_prime(r.b, b⁵′),
			(<ˢ)(lᵃ, b⁵′, sᵇ), (<ˢ)(rᵃ, b⁵′, sᵇ))
	end
	simp(r::downstream_of) = begin
		sᵇ, lᵃ, rᵃ, b³′ = var(4)
		∧(left(r.a, lᵃ), right(r.a, rᵃ), strand(r.b, sᵇ), three_prime(r.b, b³′),
			(>ˢ)(lᵃ, b³′, sᵇ), (>ˢ)(rᵃ, b³′, sᵇ))
	end
end ∘ nothing

# ╔═╡ 33c045e1-5b13-46be-9405-3f35d2f15470
md"""
There are three relations where the direction of both of the stranded intervals is relevant. These are:

|Base term|Definition|
|:---|:---------|
|$a$ *started\_by\_xy* $b$ | Stranded interval $a$ is started by $b$ at the specified ends.|
|$a$ *overlaps\_xy* $b$ | Stranded interval $a$ overlaps with $b$ at the specified ends.|
|$a$ abuts\_xy $b$ | Stranded interval $a$ touches $b$ at the specified ends.|

We will now visit each of these in turn.

"""

# ╔═╡ 24b61554-3fba-49b5-ba32-dba7415960de
md"""
The four forms of the $started\_by$ relation are as follows:

|Term|Definition|
|:---|:---------|
|$a$ *started\_by\_55* $b$| The 5' end of $a$ is started by the 5' end of $b$. |
|$a$ *started\_by\_53* $b$| The 5' end of $a$ is started by the 3' end of $b$. |
|$a$ *started\_by\_35* $b$| The 3' end of $a$ is started by the 5' end of $b$. |
|$a$ *started\_by\_33* $b$| The 3' end of $a$ is started by the 3' end of $b$. |
"""

# ╔═╡ 251d98d7-2225-4bc7-b3f0-935fa051dc30
begin
	struct started_by_55 <: StrandedTopology a::StrandedInterval; b::StrandedInterval end
	struct started_by_53 <: StrandedTopology a::StrandedInterval; b::StrandedInterval end
	struct started_by_35 <: StrandedTopology a::StrandedInterval; b::StrandedInterval end
	struct started_by_33 <: StrandedTopology a::StrandedInterval; b::StrandedInterval end
end ∘ nothing

# ╔═╡ e5524dca-0f8d-465f-b79e-71722dd62322
md"""
The simplification rules for $started\_by\_xx$ flow from their definitions:

```math
\begin{align}
started\_by\_55(a, b) & \Leftrightarrow a^{5'} = b^{5'} ∧ a^{3'} \stackrel{s_b}> b^{3'} & \text{:sim}, \\
started\_by\_53(a, b) & \Leftrightarrow a^{5'} = b^{3'} ∧ a^{3'} \stackrel{s_b}> b^{5'} & \text{:sim}, \\
started\_by\_35(a, b) & \Leftrightarrow a^{3'} = b^{5'} ∧ a^{5'} \stackrel{s_b}< b^{3'} & \text{:sim}, \\
started\_by\_33(a, b) & \Leftrightarrow a^{3'} = b^{3'} ∧ a^{5'} \stackrel{s_b}< b^{5'} & \text{:sim}.
\end{align}
```
"""

# ╔═╡ 56225c1c-2ba7-4bdd-8d1b-6891813182d8
begin
	simp(r::started_by_55) = begin
		sᵇ, a⁵′, b⁵′, a³′, b³′ = var(5)
		∧(strand(r.b, sᵇ),
			five_prime(r.a, a⁵′), five_prime(r.b, b⁵′),
			three_prime(r.a, a³′), three_prime(r.b, b³′),
			
			a⁵′ == b⁵′, (>ˢ)(a³′, b³′, sᵇ))
	end
	simp(r::started_by_53) = begin
		sᵇ, a⁵′, b⁵′, a³′, b³′ = var(5)
		∧(strand(r.b, sᵇ),
			five_prime(r.a, a⁵′), five_prime(r.b, b⁵′),
			three_prime(r.a, a³′), three_prime(r.b, b³′),
			
			a⁵′ == b³′, (>ˢ)(a³′, b⁵′, sᵇ))
	end
	simp(r::started_by_35) = begin
		sᵇ, a⁵′, b⁵′, a³′, b³′ = var(5)
		∧(strand(r.b, sᵇ),
			five_prime(r.a, a⁵′), five_prime(r.b, b⁵′),
			three_prime(r.a, a³′), three_prime(r.b, b³′),
			
			a³′ == b⁵′, (>ˢ)(a⁵′, b³′, sᵇ))
	end
	simp(r::started_by_33) = begin
		sᵇ, a⁵′, b⁵′, a³′, b³′ = var(5)
		∧(strand(r.b, sᵇ),
			five_prime(r.a, a⁵′), five_prime(r.b, b⁵′),
			three_prime(r.a, a³′), three_prime(r.b, b³′),
			
			a³′ == b³′, (>ˢ)(a⁵′, b⁵′, sᵇ))
	end
end ∘ nothing

# ╔═╡ 0edf57f6-e0e0-48c8-81a6-883cee5e4983
md"""
The four forms of the $overlaps$ relation are as follows:

|Term|Definition|
|:---|:---------|
|$a$ *overlaps\_55* $b$| The 5' end of $a$ is within $b$ and the 5' end of $b$ is within $a$.|
|$a$ *overlaps\_53* $b$| The 5' end of $a$ is within $b$ and the 3' end of $b$ is within $a$.|
|$a$ *overlaps\_35* $b$| The 3' end of $a$ is within $b$ and the 5' end of $b$ is within $a$.|
|$a$ *overlaps\_33* $b$| The 3' end of $a$ is within $b$ and the 3' end of $b$ is within $a$.|
"""

# ╔═╡ f15740a5-c318-429f-b270-f511f86f19a9
begin
	struct overlaps_55 <: StrandedTopology a::StrandedInterval; b::StrandedInterval end
	struct overlaps_53 <: StrandedTopology a::StrandedInterval; b::StrandedInterval end
	struct overlaps_35 <: StrandedTopology a::StrandedInterval; b::StrandedInterval end
	struct overlaps_33 <: StrandedTopology a::StrandedInterval; b::StrandedInterval end
end ∘ nothing

# ╔═╡ af24eddc-e056-47ed-96ad-799d12024dbb
md"""
The simplification rules for $overlaps\_xx$ follow from their definitions.

```math
\begin{align}
overlaps\_55(a, b) & \Leftrightarrow a^{5'} \stackrel{s_a}< b^{5'} \wedge a^{5'} \stackrel{s_a}> b^{3'} \wedge a^{3'} \stackrel{s_a}> b^{5'}, & \text{:simp}\\
overlaps\_53(a, b) & \Leftrightarrow a^{5'} \stackrel{s_a}< b^{3'} \wedge a^{5'} \stackrel{s_a}> b^{5'} \wedge a^{3'} \stackrel{s_a}> b^{3'}, & \text{:simp}\\
overlaps\_35(a, b) & \Leftrightarrow a^{3'} \stackrel{s_a}> b^{5'} \wedge a^{3'} \stackrel{s_a}< b^{3'} \wedge a^{5'} \stackrel{s_a} < b^{5'}, & \text{:simp}\\
overlaps\_33(a, b) & \Leftrightarrow a^{3'} \stackrel{s_a}> b^{3'} \wedge a^{3'} \stackrel{s_a}< b^{5'} \wedge a^{5'} \stackrel{s_a} < b^{3'}. & \text{:simp}
\end{align}
```
"""

# ╔═╡ 28aac5cf-fc03-469b-8976-c228779fe969
begin
	simp(r::overlaps_55) = begin
		sᵃ, a⁵′, b⁵′, a³′, b³′ = var(5)
		∧(strand(r.a, sᵃ),
			five_prime(r.a, a⁵′), five_prime(r.b, b⁵′),
			three_prime(r.a, a³′), three_prime(r.b, b³′),
			
			(<ˢ)(a⁵′, b⁵′, sᵃ), (>ˢ)(a⁵′, b³′, sᵃ), (>ˢ)(a³′, b⁵′, sᵃ))
	end
	
	simp(r::overlaps_53) = begin
		sᵃ, a⁵′, b⁵′, a³′, b³′ = var(5)
		∧(strand(r.a, sᵃ),
			five_prime(r.a, a⁵′), five_prime(r.b, b⁵′),
			three_prime(r.a, a³′), three_prime(r.b, b³′),
			
			(<ˢ)(a⁵′, b³′, sᵃ), (>ˢ)(a⁵′, b⁵′, sᵃ), (>ˢ)(a³′, b³′, sᵃ))
	end
	
	simp(r::overlaps_35) = begin
		sᵃ, a⁵′, b⁵′, a³′, b³′ = var(5)
		∧(strand(r.a, sᵃ),
			five_prime(r.a, a⁵′), five_prime(r.b, b⁵′),
			three_prime(r.a, a³′), three_prime(r.b, b³′),
			
			(>ˢ)(a³′, b⁵′, sᵃ), (<ˢ)(a³′, b³′, sᵃ), (<ˢ)(a⁵′, b⁵′, sᵃ))
	end
	
	simp(r::overlaps_33) = begin
		sᵃ, a⁵′, b⁵′, a³′, b³′ = var(5)
		∧(strand(r.a, sᵃ),
			five_prime(r.a, a⁵′), five_prime(r.b, b⁵′),
			three_prime(r.a, a³′), three_prime(r.b, b³′),
			
			(>ˢ)(a³′, b³′, sᵃ), (<ˢ)(a³′, b⁵′, sᵃ), (<ˢ)(a⁵′, b³′, sᵃ))
	end
end ∘ nothing

# ╔═╡ ad122b57-7fa0-42be-81b8-132ed26a6866
md"""
The four forms of the $abuts$ relation are as folows:


|Term|Definition|
|:---|:---------|
|?a abuts\_55 ?b| The 5' end of $?a$ touches but does not overlap the 5' end of $?b$.|
|?a abuts\_53 ?b| The 5' end of $?a$ touches but does not overlap the 3' end of $?b$.|
|?a abuts\_35 ?b| The 3' end of $?a$ touches but does not overlap the 5' end of $?b$.|
|?a abuts\_33 ?b| The 3' end of $?a$ touches but does not overlap the 3' end of $?b$.|
"""

# ╔═╡ 40920bd0-c398-44f2-b718-677d8ba6a441
begin
	struct abuts_55 <: StrandedTopology a::StrandedInterval; b::StrandedInterval end
	struct abuts_53 <: StrandedTopology a::StrandedInterval; b::StrandedInterval end
	struct abuts_35 <: StrandedTopology a::StrandedInterval; b::StrandedInterval end
	struct abuts_33 <: StrandedTopology a::StrandedInterval; b::StrandedInterval end
end ∘ nothing
	

# ╔═╡ f890dea4-e520-4697-bd1c-f685f2c3a509
md"""
The simplification rules for $abuts\_xx$ follow from their definitions.

```math
\begin{align}
abuts\_55(a, b) & \Leftrightarrow a^{5'} \stackrel{s_a}< b^{5'} \wedge touches(a^{5'},b^{5'}), & \text{:simp}\\
abuts\_53(a, b) & \Leftrightarrow a^{5'} \stackrel{s_a}< b^{3'} \wedge touches(a^{5'},b^{3'}), & \text{:simp}\\
abuts\_35(a, b) & \Leftrightarrow a^{3'} \stackrel{s_a}> b^{5'} \wedge touches(a^{3'},b^{5'}), & \text{:simp}\\
abuts\_33(a, b) & \Leftrightarrow a^{3'} \stackrel{s_a}> b^{3'} \wedge touches(a^{3'},b^{3'}). & \text{:simp}\\
\end{align}
```
"""

# ╔═╡ 219b2396-8ef6-4230-a599-8b8ce4d577ad
md"""
# A Literate Programming Decision System for Biopolymer Composition Constraints

The motivation of this section is to demonstrate a minimal system capable of solving constraint problems using the terminology defined here.
It is primarily intended as a reference implementation.

This will be implemented as a pseudo-tableux solver.
Axioms will be recursively evaluated.
This will potentially generated subsidiary axioms.
Those that represent some fact that isn't reducible to their sub-axioms will record this into a model.
Once all axiomis have been absorbed into the model and none remain, the axiom set has been checked, and is distilled into the model.
If at any point this proces finds an axiom that conflicts with the model, the proces stops and the set of axioms, given this model, is considered contradictory.
"""

# ╔═╡ dcc42c3a-d74a-4505-9360-0dda1e159fb7
md"""
## Setting things up.

Firstly we need to provide some concrete types for all the various abstract types used above. We are going to use meaningful strings for named entities.
"""

# ╔═╡ 75954adf-e970-4353-95e3-86d0548e4ad1
begin
	struct NamedPoint <: PointRep name::String end	
	struct NamedInterval <: IntervalRep name::String end
	struct NamedStrandedInterval <: StrandedIntervalRep name::String end
end ∘ nothing

# ╔═╡ 6b960fe3-480e-4852-be70-3ffe63efe770
begin
	display_label(r::Axiom) = display_label(typeof(r))
	display_label(t::Type) = string(t.name.name)
	display_label(v::Var) = join(["?", v.id])
	display_label(n) = n.name
	display_label(s::StrandRep) = s.name
	
	# pretty-print, but without type information
	Base.show(io::IO, r::Relation) = print(io, 
			getfield(r, 1),
			" ",
			display_label(r),
			" ",
			getfield(r, 2))
	Base.show(io::IO, e::Entity) = print(io, display_label(e))
end

# ╔═╡ 9155d44b-3600-40f9-8b87-4ea848f3f136
md"""
### Knowlegebase

The knowledgebase struct represents all the axioms that have not yet been analysed.
This is essentially a conjunction of axioms.
We will store them in a last-in-first-out queue, modelled by lists and `push!` and `pop!`.
We can also provide some convenience methods to tell a knowledgebase new axioms so that you can describe your design, and so that it can be updated during reasoning.
"""

# ╔═╡ cc57b360-10b0-41f3-96d8-85d02314ae0c
begin
	struct KnowledgeBase
		axioms::Vector{Axiom}
		function KnowledgeBase() new(Vector()) end
	end
		
	tell!(kb::KnowledgeBase, ax::Axiom) = begin push!(kb.axioms, ax); kb end
	tell!(kb::KnowledgeBase, ax::(∧)) = begin tell!(kb, ax.axioms); kb; end
	tell!(kb::KnowledgeBase, axs) = begin
		for a in axs
			tell!(kb, a)
		end
		kb
	end
	tell!(kb::KnowledgeBase = KnowledgeBase()) = (ax...) -> begin
		for a in ax tell!(kb, a) end
		kb
	end
	
	
end ∘ nothing

# ╔═╡ 68e1782b-52ed-4606-a774-a776f9f3a443
md"""
### The LacI/TetR inverter

Armed with a knowledgebase API, we can build something.
In this case, we will use the cannonical synthetic biology example of a simple design for a LacI/TetR inverter, similar to that in the [SBOL Designer](https://doi.org/10.1021/acssynbio.5b00244) paper.
"""

# ╔═╡ 152e1c21-9f74-49a1-892a-728034975890
begin
	function tetR_inverter(kb = KnowledgeBase())
		TetR_Inverter = NamedStrandedInterval("TetR_Inverter")

		pTetR = NamedStrandedInterval("pTetR")
		lacI = NamedStrandedInterval("lacI")
		ECK_1 = NamedStrandedInterval("ECK_1")

		inverter_parts = [pTetR, lacI, ECK_1]

		tell!(kb)(
			[same_strand(TetR_Inverter, i) for i in inverter_parts],
			strand(TetR_Inverter, TOP_STRAND),
		    [contains(TetR_Inverter, i) for i in inverter_parts],
		    [before(a, b) for (a, b) in
					zip(inverter_parts, inverter_parts[2:end])])
	end
	
	function lacI_inverter(kb = KnowledgeBase())
		LacI_Inverter = NamedStrandedInterval("LacI_Inverter")
		
		pLacI = NamedStrandedInterval("pLacI")
		tetR = NamedStrandedInterval("tetR")
		gfp = NamedStrandedInterval("gfp")
		ECK_2 = NamedStrandedInterval("ECK_2")
		
		inverter_parts = [pLacI, tetR, gfp, ECK_2]

		tell!(kb)(
			[same_strand(LacI_Inverter, i) for i in inverter_parts],
			[contains(LacI_Inverter, i) for i in inverter_parts],
			[before(a, b) for (a, b) in
					zip(inverter_parts, inverter_parts[2:end])])
	end
	
	function inverter(kb = KnowledgeBase())
		tetR_inverter(kb)
		lacI_inverter(kb)
		
		TetR_Inverter = NamedStrandedInterval("TetR_Inverter")
		LacI_Inverter = NamedStrandedInterval("LacI_Inverter")
	
		tell!(kb, does_not_overlap(TetR_Inverter, LacI_Inverter))
	end
end ∘ nothing

# ╔═╡ 5861e4b9-fe7a-4fd4-8523-d81d66020b23
md"""
We can evaluate `inverter()` to get back a knowledgebase representing this information.
It contains 21 axioms.
"""

# ╔═╡ 5d02fd10-3849-4862-b46a-f64604f876aa
inverter()

# ╔═╡ f896cd78-4331-4c46-af00-45e3e59bc4f1
md"""
This isn't particularly easy to read, but you can see how it relates to what we expressed above.
We can take the inverter and apply one pass of the simplification and normalization rules over it, to get an expanded graph.
"""

# ╔═╡ c2420dbd-c559-433f-b1d3-25841a444f6d
function simp_norm(a)
	na = norm(a)
	a = isnothing(na) ? a : na
	sa = simp(a)
	isnothing(sa) ? a : sa
end

# ╔═╡ e2eb656e-dda1-4916-994b-b9df1703ab47
tell!()([simp_norm(a) for a in inverter().axioms])

# ╔═╡ 045f8edb-0de0-4074-82f6-f947e909c61a
md"""
If you look through these, you will see that the $(length(inverter().axioms)) fairly readable axioms have been transformed into $(length(tell!()([simp_norm(a) for a in inverter().axioms]).axioms)) unreadable ones, involving a lot of variables.
It is impossible to understand what is going on by reading them.

If we plot these two knowledgebases as semantic graphs, you can see the general structure of these axioms. There is a hub for each inverter, and links between their components. In the expanded version, essentially the same structure exists except that many of the links are now replaced with multiple relations between nodes representing variables.
"""

# ╔═╡ dd71ef7b-d7e2-48ed-a397-f78e971a6f47
begin
	function kbplot(kb::KnowledgeBase)
		nodes = Dict{Entity, Int}()
		edges = Vector()
		
		function visit(r::Relation)
			s, d = [get!(nodes, n, length(nodes)+1)
				for n in [getfield(r, 1), getfield(r, 2)]]
			push!(edges, (s, d, r))
		end
		function visit(or::∨)
			visit(or.axioms)
		end
		function visit(as::Set{Axiom})
			for a in as visit(a) end
		end
		function visit(as::Vector{Axiom})
			for a in as visit(a) end
		end
		function visit(a::Axiom)
			println("Skipping $a")
		end

		visit(kb.axioms)

		g = SimpleDiGraph(length(edges))

		edge_labels = Dict()
		for (s, d, a) in edges
		  edge_labels[(s, d)] = display_label(a)
		end
		
 		for (s, d, a) in edges
 			add_edge!(g, s, d)
 		end

		node_labels = Vector(undef, length(nodes))
		for (e, n) in nodes
			l = display_label(e)
			if startswith(l, "?") l = "" end
			node_labels[n] = l
		end
		
		graphplot(g, names=node_labels, edgelabel=edge_labels, nodeshape=:circle, nodesize=0.05)
	end
end ∘ md"""<HIDDEN CODE>"""

# ╔═╡ 39cf4b15-2999-4a90-8933-0f5f6e736e33
let
	kb₀ = inverter()
	kb₁ = tell!()([simp_norm(a) for a in kb₀.axioms])
		
	plot(kbplot(kb₀), kbplot(kb₁), layout=(1,2))
end

# ╔═╡ 4b095876-54fa-4da3-89ea-76f15a1a7299
md"""
### The Model and the Decision Procedure

Our reasoning procedure will work by building a semantic model from the axioms.
The model is a representation of all the axioms that have been processed so far.
Two methods, `reason!` and `∋` (\ni) allow interactions. The first attempts to build a model given axioms, and the second tests if an axiom is already known by a model.

The reasoning procedure will take an axiom from the knowledge set, and then apply rules to it.
The rule will do the following:

* if the axiom can be re-written, rewrite it and add the rewritten axioms to the knowledgebase
* if the axiom leads to a branch, clone the reasoning state, reason over all branches and then unify them
* if the axiom would modify the model then check if this modification would contradict what is known in the model
  + if there is a conflict, "close" this branch with a contradiction
  + if there is no conflict, update the model and return an iterator over the singleton of the successful reasoning state

The result of this is to absorb all the axioms into the model.
If the axioms are consistent, then they will be absorbed without conflict, and the resulint model summarises all of the axioms.
Otherwise, there was an inconsistency.
"""

# ╔═╡ 6356184b-e031-44cf-aef1-ae57299ff061
begin
	"A full model"
	abstract type Model end
	
	"""
	Test if a model is known to contain an axiom.
	This is a direct test of the model state.
	It should perform no inference.
	"""
	function (∋)(model, ax::Axiom)::Bool  false end
	
	"The reasoning procedure state."
	struct ReasoningState
		kb::KnowledgeBase
		model::Model
		unhandled::Set{Axiom}
	end
end ∘ nothing

# ╔═╡ a96ed46f-19e3-454f-b894-70b81c6e4928
md"""
Right away we can implement the top-level loop.
"""

# ╔═╡ b8c33ed8-4171-4225-b27d-9bb9dbe8f8ed
begin
	function reason!(rs::ReasoningState;
			rewrite = (from, to, rule) -> nothing,
			branch = (from, alternative) -> nothing,
			contradicts = (of, with) -> nothing,
			unsatisfiable = (at) -> nothing,
			completed = () -> nothing)
		while true
			# inconsistency
			isnothing(rs) && return
			
			# solution
			isempty(rs.kb.axioms) && return rs

			ax = pop!(rs.kb.axioms)
			rs = reason!(ax, rs; rewrite = rewrite, branch = branch, contradicts = contradicts, completed = completed)
		end
	end
end ∘ nothing

# ╔═╡ e86a9992-0386-4206-b9d4-99120e754a14
md"""
The default reasoning rule is to apply normalization and simplification.
If this fails, then the axiom is unhandled.
Each axiom that requires specific handling will need to provide their own method that will be called in place of this default, to do the specific work they need to do.
"""

# ╔═╡ 5427db44-4010-4d29-b46a-82175971459f
begin
	function reason!(ax::Axiom, rs::ReasoningState; kwargs...)
		# normalize
		ax_norm = norm(ax)
		if !isnothing(ax_norm)
			kwargs.rewrite(ax, ax_norm, "norm")
			tell!(rs.kb, ax_norm)
			return rs
		end
		
		# simplify
		ax_simp = simp(ax)
		if !isnothing(ax_simp)
			kwargs.rewrite(ax, ax_simp, "simp")
			tell!(rs.kb, ax_simp)
			return rs
		end
		
		# unhandled axiom
		push!(rs.unhandled, ax)
		return rs
	end
end ∘ nothing

# ╔═╡ f8fd23b4-1bf2-4345-831a-bb3e17a8dbbe
md"""
Next we can provide implementations for the logic constants.
"""

# ╔═╡ 5c7512d6-ac5f-4e83-95be-b4fe6c8930ec
begin
	"True is consistent"
	function reason!(::_⊤, rs::ReasoningState; kwargs...)
		kwargs.completed()
		rs
	end
	
	"False is inconsistent"
	function reason!(::_⊥, ::ReasoningState; kwargs...)
		kwargs.unsatisfiable(⊥)
		nothing
	end
end ∘ nothing

# ╔═╡ 940e67f8-fcca-402d-b9b2-488f7b7b161a
md"""
The implementation of conjunction is trivial - it just unpacks the axioms and puts them into the knowledge base.
Disjunction is more tricky.
It forks the reasoning state for each sub-clause, and then combines the results.
"""

# ╔═╡ 26e3f6fc-41b0-445c-bdee-314720d9fae9
md"""
From here on, we will need to provide `reason!` methods that interact with the model.
We will work through those below.
"""

# ╔═╡ f2d51612-2f92-4638-9fe8-cf12512efc05
md"""
### Sub-models

The model will be composed of several sub-models.
Each sub-model deals with a particular domain of facts, and understands a particular sub-set of the relations.
They will work together to reason about the full terminology.
"""

# ╔═╡ 033ee922-46f7-4488-b7ef-4abd0ec24e13
begin
	"A submodel of a full model, modelling a specific domain."
	abstract type Submodel end
	
	"""
	Initialize the model after construct, before use.
	This must be called by the `model` after it is built but before it is used.
	"""
	function modelinit!(model::Model, m::Submodel) end
end ∘ nothing

# ╔═╡ c432cee9-2cca-4b47-92c5-e053dc8c62e9
md"""
## Interpretation sets

Our model contains variables as well as named entities.
Different expressions may use different variables to refer to the same things.
It is also possible that a single thing has multiple names.
A standard way to handle this is to manipulate sets of equivalent entities, called an interpretation.
Then each data structure that needs to book-keep entities can either index into interpretations, or can store references to the interpretations directly.
"""

# ╔═╡ 6fa42bc1-831f-4ea8-bb10-c8bef8b73a62
begin
	"An interpretation set"
	struct Interpretation
		I::Set{Entity}
		Interpretation() = new(Set())
		Interpretation(e::Entity) = new(Set([e]))
	end
	
	Base.union(i::Interpretation, is...) = Interpretation(
		Base.union(i.I, [j.I for j in is])
		)
end

# ╔═╡ b7da0322-7120-4659-b1e2-a268c58458cf
begin
	"Conjunction simply unpacks its axioms into the knowledge base"
	function reason!(conjunction::∧, rs::ReasoningState; kwargs...)
		tell!(rs.kb, conjunction)
		rs
	end
	
	"Disjunction forks the reasoning state for each option and then combines them."
	function reason!(disjunction::∨, rs₀::ReasoningState; kwargs...)
		# empty disjunction is satisfied by fiat
		if isempty(disjunction.axioms)
			kwargs.satisfied(disjunction)
			return rs
		end
		
		# run a new reasoning session rooted at each disjunctive clause
		solutions = []
		for ax in disjunction.axioms
			kwargs.branch(disjunction, ax)
			
			# we're going to start with a new reasoning state
			rs = ReasoningState(KnowledgeBase([ax]), deepcopy(rs.model), Set())
			res = reason!(rs; kwargs)
			!isnothing(res) && push!(solutions, res)
		end
		
		# if no branches 
		if isempty(solutions)
			kwargs.unsatisfiable(disjunction)
			return nothing
		end
		
		# things true in each possible worlds are true
		model = intersect([s.model for s in solutions])
		
		# axioms not handled in any possible world are unhandled
		unhandled = union([s.unhandled for s in solutions])
		
		return ReasoningState(rs₀.kb, model, unsatisfied)
	end
	
end ∘ nothing


# ╔═╡ 74503e0c-4d81-4416-8757-945273c8d5cf
md"""
### Equality model

The most important model is the equality model.
This tracks sets of values that are equivalent, as well as pairs of values that are non-equivalent.
"""

# ╔═╡ 9279e3eb-7c1f-42e8-a077-859b836e4304
md"""
We will begin with the model for equivalency and non-equivalency.


Equivalency will be modelled as disjoint interpretations.
Each member of an equivalence set will have an entry in a map to the exact same interpretation.
Operations will take care to ensure that all interpretations are always disjoint.

Inequality is different, since it is not a transitive relation.
Here we store a map of sets of interpretations, each one capturing a single non-equivalent relationship.

We will define an operator function `∋ᴵ` that retrieves an interpretation for an entitie in a model.
"""

# ╔═╡ 8c3ef4ff-fe57-40c4-a999-6f2c3dc02883
begin
	"Tracks equality assertions and inequalities."
	struct EqualityModel <: Submodel
		"The interpretation of a value as the maximal set of known equivalent values."
		interp::Dict{Entity, Interpretation}
		"The set of known non-equal entities."
		different::Dict{Entity, Set{Interpretation}}
		function EqualityModel() new(Dict(), Dict()) end
	end
	
	"""
	Find the current interpretation of x in the model.
	If the entity wasn't previously known,
	update the model to include the singleton identity.
	"""
	(∋ᴵ)(model::Model, x::Entity)::Interpretation =
		get!(() -> Interp(x), model.equality.interp, x)
end ∘ nothing

# ╔═╡ 66beb2f6-7f31-49e2-877c-d6f18e3b4453
md"""
We can now define `∋` and `reason!` for inequality.
"""

# ╔═╡ 8fafde27-504a-43b9-ad4f-db6561784d1e
begin

	"""Test non-equivalence by testing
	if the different set of one contains the interpretation of the other."""
	(∋)(model::Model, r::≄) = let
		diff_a = get!(() -> Set(), model.equality.different, r.a)
		(model ∋ᴵ r.b) ∈ diff_a
	end

	"Inequality is rememberd by storing each participant in the inequality set of the other."
	function reason!(r::≄, rs::ReasoningState; kwargs...)
		aᴵ = rs.model ∋ᴵ r.a
		bᴵ = rs.model ∋ᴵ r.b
		
		# non-equivalence is contradicted if they are equivalent.
		# this is the same as their interpretations being equivalent.
		if aᴵ ≡ bᴵ
			kwargs.conflict(r, r.a ≃ r.b)
			return nothing
		end
		
		# push the interpretations of b and a into the difference sets of a and b
		diff_a = get!(rs.model.equality.different, r.a, Set())
		push!(diff_a, bᴵ)
		diff_b = get!(rs.model.equality.different, r.b, Set())
		push!(diff_b, aᴵ)
		
		rs
	end

end ∘ nothing

# ╔═╡ 39d9c535-7e07-4e6e-9337-e7da36764509
md"""
Defining `reason!` for equality is a bit more involved.
All the other sub-models will be affected by merging the interpretations of two entities.
So prior to merging, all the sub-models need to be informed.
They each get a chance to veto it as causing an inconsistency.
Otherwise the interpretations are merged, such that they all  point to a single, shared set.
"""

# ╔═╡ 4d8aee6b-cc05-4d67-9492-32b39f763b03
begin
	
	"Test equivalence by looking in the interpretations."
	(∋)(model::Model, r::≃) = r.a ∈ interp!(model, r.b)

	"""
	Rewriting equality merges the interpretations of the two values.
	The equality can't be absorbed into the model if any other sub-model vetos it.
	"""
	function rewrite!(r::≃, rs::ReasoningState; kwargs...)
		aᴵ = interp!(model, r.a)
		bᴵ = interp!(model, r.b)
		
		# nothing to do
		if aᴵ ≡ bᴵ
			kwargs.consistent(r)
			return rs
		end
		
		abᴵ = union(aᴵ, bᴵ)
		
		#give all submodels a chance to veto it
		for sm in submodels(rs.model)
			rs = prepare_merge!(rs, sm, r, aᴵ, bᴵ, abᴵ; kwargs)
			if isnothing(rs)
				# we got vetoed
				return nothing
			end
		end

		for i in abᴵ
			rs.model.equality.interp[i] = abᴵ # reassign identities
		end
			
		rs
	end
end ∘ nothing

# ╔═╡ 50551abf-44d2-4050-9c1a-c1c0acfe9b8b
md"""
We actually have an opportunity to implement `prepare_merge!` for the equality mode itself.
The `different` part of the model may notice that entities begin merged are in fact known to be different.
"""

# ╔═╡ b95983f9-65fc-4148-9dcf-9db248a5416d
begin
	function prepare_merge(rs::ReasoningState, ::EqualityModel, r::≃,
			aᴵ::Set{Entity}, bᴵ::Set{Entity}, abᴵ::Set{Entity}; kwargs...)
		# we need to check that 
		
	end
end ∘ nothing

# ╔═╡ 89eb9447-6417-4633-8738-fb56b5a7589e
md"""
### Strand model

This model records strand axioms.
These may assert that a stranded region sits on the top or bottom strand.

We will keep a map from stranded regions to the interpretation of all strands for it.
Stranded regions that share an interpretation will have individual entries pointing to the same interpretation set of strands.

An interpretatio of strands is inconsistent if it contains both the top and bottom strand.
"""

# ╔═╡ e221e01c-2eb0-4b2b-950f-36398edc2aee
begin
	"""
	Model of strand associations.
	
	Stranded intervals map to an entity that represents their strand.
	"""
	struct StrandModel
		strand_of::Dict{StrandedInterval, Set{Strand}}
	end
end ∘ nothing

# ╔═╡ 0d51605a-a0d0-4471-b0f7-5773ae9b480d
md"""
Firstly we can provide `∋` and `rewrite!` for `strand`.
We're going to track a single strand association for each stranded item.
"""

# ╔═╡ 071b1c6a-9eca-4fb5-9c45-082b6249c191
begin
	(∋)(model::Model, r::strand) = r.s ∈ model.strand.strand_of[r.a]
	
	function rewrite!(r::strand, rs::ReasoningState; kwargs...)
		aᴵ = interp!(rs.model, r.a)
		sᴵ = interp!(rs.model, r.s)
		
		s = get!(rs.model.strand.strand_of, r.a, nothing)

		if isnothing(s)
			# this is new - set the strand_of entries up
			for a ∈ aᴵ
				rs.model.strand.strand_of[a] = sᴵ
			end
		elseif s ∈ sᴵ
			# we allready knew this
		else
			# we have a new strand value in addition to an old one
			# so they must be equivalent
			tell!(rs.kb, first(s) ≃ r.s)
		end

		rs
	end
end ∘ nothing

# ╔═╡ 52be65d2-944d-4788-8584-0d2a6244d91e
md"""
Next we handle merging.
"""


# ╔═╡ 23287766-7d08-4740-b180-e55d8f987c56
begin
	function prepare_merge(rs::ReasoningState, ::StrandModel, aᴵ::Set{Entity}, bᴵ::Set{Entity}, abᴵ::Set{Entity}; kwargs...)
		# the merge should be prevented
		# if it would attempt to merge the top and bottom strand
		if TOP_STRAND ∈ abᴵ && BOTTOM_STRAND ∈ abᴵ
			kwargs.unsatisfiable(TOP_STRAND ≃ BOTTOM_STRAND)
			return nothing
		end
		
		# replace all strands matching either interpretation
		# with the combined one
		for sr ∈ keys(rs.model.strand.strand_of)
			s = rs.model.strand.strand_of[sr]
			if s ≡ aᴵ || s ≡ bᴵ
				rs.model.strand.strand_of[sr] = abᴵ
			end
		end
	end
end ∘ nothing

# ╔═╡ 64d51f37-91a1-4a4e-8976-9ab81c7a50a3
md"""
### Points model

Our model for points needs to track which points are strictly less than others.
"""

# ╔═╡ 01d431bc-421e-4e81-adde-5d715acafbb2
begin
	struct PointModel
		"""
		The strictly less-than set.
		Maintains the transitive closure of the less-than relation.
		"""
		less_than::Dict{Point, Set{Point}}
		PointModel() = new(Dict())
	end
	
	"Retrieve the equality model from a larger model."
	point_model(model::PointModel) = model
	
	function rewrite!(model::Model, r::(<))
		less_than = point_model(model).less_than
		
		# a<b is inconsistent if a=b or a>b
		# we can check the former by rewriting a≃b and checking for conflict
		
		<ᵃ = m.less_than[r.a]
		append!(<ᵃ, r.b)
	end
	
	function modelinit!(model::Model, m::PointModel) end
end ∘ nothing

# ╔═╡ f5d99600-d281-4de8-8c7c-b4b8ed934eb5
md"""
### Interval Model

Our model for intervals needs to track which points are associated with the left and right ends of intervals.
"""

# ╔═╡ e2348d82-005e-458f-8b9b-a8e07e3b14ee
begin
	struct IntervalModel
		left_of::Dict{Interval, Point}
		right_of::Dict{Interval, Point}
		IntervalModel() = new(Dict(), Dict())
	end
	
	"Retrieve the interval model from a larger model."
	interval_model(model::IntervalModel) = model
	
	function remember!(model::Model, r::left)
		of = get!(left_of, r.a, Set())
		push!(of, r.p)
	end
	
	function remember!(model::Model, r::right)
		of = get!(right_of, r.a, Set())
		push!(of, r.p)
	end
	
	function modelinit!(model::Model, m::IntervalModel) end
end
		

# ╔═╡ 86a0442c-a689-4192-95e4-90e30620d584
md"""
### Full Model

We could add models to track other domains, for example, integer assignments to absolute point positions. This is beyond the scope of this work.

We can now define a composite model and provide accessors so that it can be used by these methods.
"""

# ╔═╡ 4ae17f1b-37bb-40ca-8202-162a38a8da9c
begin
	struct FullModel <: Model
		equality_model::EqualityModel
		strand_model::StrandModel
		point_model::PointModel
		interval_model::IntervalModel
		FullModel() = new(EqualityModel(), StrandModel(), PointModel(), IntervalModel())
	end

	equality_model(model::FullModel) = model.equality_model
	strand_model(model::FullModel) = model.strand_model
	point_model(model::FullModel) = model.point_model
	interval_model(model::FullModel) = model.interval_model
end ∘ nothing

# ╔═╡ 360fef9d-e3fa-4ea9-80d9-978adb5f12c8
function modelinit!(model::FullModel)
	modelinit!(model, model.equality_model)
	modelinit!(model, model.strand_model)
	modelinit!(model, model.point_model)
	modelinit!(model, model.interval_model)
end

# ╔═╡ bbe57268-af9e-41a0-92a5-b9620fcfde45
md"""
### Building a model from a knowledgebase

A knowledgebase is just a collection of axioms, all of which are assumed to hold.
However, they may contain contradictory statements, either explicitly or by implication.
The process of checking for consistency builds a model from a knowledgebase.
During the building of the model, any contradictory axioms or implications are discovered, and the process halted.
Consistent knowledgebases have  at least one model, and inconsistent knowledgeabases have no models.
"""

# ╔═╡ acdaf483-3269-4916-bcbb-6f25a15d32b2
md"""
Let's test this with the inverter example.
"""

# ╔═╡ 054e5c93-8bc7-46df-ae99-6290edff8136
md"""
We also need to provide model ops for our fundamental axioms.
"""

# ╔═╡ 5d033a83-2467-4e62-b4a2-e6922720d7a9
begin
	function model!(kb::Knowledgebase, model::Model, ax::strand)
		if known!(model, ax)
			return model
		end
		
		model′ = deepcopy(model)
		t = var()
		model!(kb, model′, ax.s ≄ t)
		model!(kb, model',
		
		if isnothing(sᵏ)
			remember!(model, ax)
		elseif ax.s != sᵏ
			println("Conflict between s=$(ax.s) and sᵏ=$(sᵏ) for $(ax.a)")
			return # conflict
		else
			model
		end
	end
end ∘ nothing

# ╔═╡ 09f37ea7-dfdc-49a9-9b12-1390f06cca83
with_terminal() do
	model(inverter())
end

# ╔═╡ 2f668655-7aa0-4031-9303-c446f6a95808
md"""
# Appendix

*Type hierarchy of axioms*
"""

# ╔═╡ 4fe44dfb-c001-4039-be4b-eba67cb73a44
begin
	function type_diagram(io, t)
		ids = Dict()
		
		println(io, "blockdiag {")
		visit_type(io, t, nothing; ids=ids)
		println(io, "}")
	end
	
	function diagram_node(io, t; ids)
		node_id = get!(ids, t, join(["node_", length(ids)]))
		node_name = display_label(t)
		#node_name = string(t)
		println(io, node_id, " [label = \"", node_name,"\"];")
		node_id
	end
	
	function visit_type(io, t, p; ids)
		n = diagram_node(io, t; ids=ids)
		if !isnothing(p)
			println(io, p, " -> ", n)
		end
		for ts in subtypes(t)
			visit_type(io, ts, n; ids=ids)
		end
	end
	buff = IOBuffer()
	type_diagram(buff, Axiom)
	take!(buff) |> String |> (s) -> Kroki.Diagram(:blockdiag, s) 
end

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
AbstractTrees = "1520ce14-60c1-5f80-bbc7-55ef81b5835c"
GraphRecipes = "bd48cda9-67a9-57be-86fa-5b3c104eda73"
Kroki = "b3565e16-c1f2-4fe9-b4ab-221c88942068"
LightGraphs = "093fc24a-ae57-5d10-9952-331d41423f4d"
Luxor = "ae8d54c2-7ccd-5906-9d76-62fc9837b5bc"
Plots = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
UUIDs = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[compat]
AbstractTrees = "~0.3.4"
GraphRecipes = "~0.5.7"
Kroki = "~0.1.0"
LightGraphs = "~1.3.5"
Luxor = "~2.14.0"
Plots = "~1.20.0"
PlutoUI = "~0.7.9"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

[[AbstractFFTs]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "485ee0867925449198280d4af84bdb46a2a404d0"
uuid = "621f4979-c628-5d54-868e-fcf4e3e8185c"
version = "1.0.1"

[[AbstractTrees]]
git-tree-sha1 = "03e0550477d86222521d254b741d470ba17ea0b5"
uuid = "1520ce14-60c1-5f80-bbc7-55ef81b5835c"
version = "0.3.4"

[[Adapt]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "84918055d15b3114ede17ac6a7182f68870c16f7"
uuid = "79e6a3ab-5dfb-504d-930d-738a2a938a0e"
version = "3.3.1"

[[ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"

[[ArnoldiMethod]]
deps = ["LinearAlgebra", "Random", "StaticArrays"]
git-tree-sha1 = "f87e559f87a45bece9c9ed97458d3afe98b1ebb9"
uuid = "ec485272-7323-5ecc-a04f-4719b315124d"
version = "0.1.0"

[[Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[AxisAlgorithms]]
deps = ["LinearAlgebra", "Random", "SparseArrays", "WoodburyMatrices"]
git-tree-sha1 = "a4d07a1c313392a77042855df46c5f534076fab9"
uuid = "13072b0f-2c55-5437-9ae7-d433b7a33950"
version = "1.0.0"

[[Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[Bzip2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "c3598e525718abcc440f69cc6d5f60dda0a1b61e"
uuid = "6e34b625-4abd-537c-b88f-471c36dfa7a0"
version = "1.0.6+5"

[[Cairo]]
deps = ["Cairo_jll", "Colors", "Glib_jll", "Graphics", "Libdl", "Pango_jll"]
git-tree-sha1 = "d0b3f8b4ad16cb0a2988c6788646a5e6a17b6b1b"
uuid = "159f3aea-2a34-519c-b102-8c37f9878175"
version = "1.0.5"

[[Cairo_jll]]
deps = ["Artifacts", "Bzip2_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "JLLWrappers", "LZO_jll", "Libdl", "Pixman_jll", "Pkg", "Xorg_libXext_jll", "Xorg_libXrender_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "e2f47f6d8337369411569fd45ae5753ca10394c6"
uuid = "83423d85-b0ee-5818-9007-b63ccbeb887a"
version = "1.16.0+6"

[[ChainRulesCore]]
deps = ["Compat", "LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "bdc0937269321858ab2a4f288486cb258b9a0af7"
uuid = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
version = "1.3.0"

[[CodecZlib]]
deps = ["TranscodingStreams", "Zlib_jll"]
git-tree-sha1 = "ded953804d019afa9a3f98981d99b33e3db7b6da"
uuid = "944b1d66-785c-5afd-91f1-9de20f533193"
version = "0.7.0"

[[ColorSchemes]]
deps = ["ColorTypes", "Colors", "FixedPointNumbers", "Random"]
git-tree-sha1 = "9995eb3977fbf67b86d0a0a0508e83017ded03f2"
uuid = "35d6a980-a343-548e-a6ea-1d62b119f2f4"
version = "3.14.0"

[[ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "32a2b8af383f11cbb65803883837a149d10dfe8a"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.10.12"

[[ColorVectorSpace]]
deps = ["ColorTypes", "FixedPointNumbers", "LinearAlgebra", "SpecialFunctions", "Statistics", "TensorCore"]
git-tree-sha1 = "42a9b08d3f2f951c9b283ea427d96ed9f1f30343"
uuid = "c3611d14-8923-5661-9e6a-0046d554d3a4"
version = "0.9.5"

[[Colors]]
deps = ["ColorTypes", "FixedPointNumbers", "Reexport"]
git-tree-sha1 = "417b0ed7b8b838aa6ca0a87aadf1bb9eb111ce40"
uuid = "5ae59095-9a9b-59fe-a467-6f913c188581"
version = "0.12.8"

[[Compat]]
deps = ["Base64", "Dates", "DelimitedFiles", "Distributed", "InteractiveUtils", "LibGit2", "Libdl", "LinearAlgebra", "Markdown", "Mmap", "Pkg", "Printf", "REPL", "Random", "SHA", "Serialization", "SharedArrays", "Sockets", "SparseArrays", "Statistics", "Test", "UUIDs", "Unicode"]
git-tree-sha1 = "79b9563ef3f2cc5fc6d3046a5ee1a57c9de52495"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "3.33.0"

[[CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"

[[Contour]]
deps = ["StaticArrays"]
git-tree-sha1 = "9f02045d934dc030edad45944ea80dbd1f0ebea7"
uuid = "d38c429a-6771-53c6-b99e-75d170b6e991"
version = "0.5.7"

[[DataAPI]]
git-tree-sha1 = "ee400abb2298bd13bfc3df1c412ed228061a2385"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.7.0"

[[DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "7d9d316f04214f7efdbb6398d545446e246eff02"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.10"

[[DataValueInterfaces]]
git-tree-sha1 = "bfc1187b79289637fa0ef6d4436ebdfe6905cbd6"
uuid = "e2d170a0-9d28-54be-80f0-106bbe20a464"
version = "1.0.0"

[[Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[DelimitedFiles]]
deps = ["Mmap"]
uuid = "8bb1440f-4735-579b-a4ab-409b98df4dab"

[[Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"

[[DocStringExtensions]]
deps = ["LibGit2"]
git-tree-sha1 = "a32185f5428d3986f47c2ab78b1f216d5e6cc96f"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.8.5"

[[Downloads]]
deps = ["ArgTools", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"

[[EarCut_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "92d8f9f208637e8d2d28c664051a00569c01493d"
uuid = "5ae413db-bbd1-5e63-b57d-d24a61df00f5"
version = "2.1.5+1"

[[Expat_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "b3bfd02e98aedfa5cf885665493c5598c350cd2f"
uuid = "2e619515-83b5-522b-bb60-26c02a35a201"
version = "2.2.10+0"

[[FFMPEG]]
deps = ["FFMPEG_jll"]
git-tree-sha1 = "b57e3acbe22f8484b4b5ff66a7499717fe1a9cc8"
uuid = "c87230d0-a227-11e9-1b43-d7ebe4e7570a"
version = "0.4.1"

[[FFMPEG_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "JLLWrappers", "LAME_jll", "LibVPX_jll", "Libdl", "Ogg_jll", "OpenSSL_jll", "Opus_jll", "Pkg", "Zlib_jll", "libass_jll", "libfdk_aac_jll", "libvorbis_jll", "x264_jll", "x265_jll"]
git-tree-sha1 = "3cc57ad0a213808473eafef4845a74766242e05f"
uuid = "b22a6f82-2f65-5046-a5b2-351ab43fb4e5"
version = "4.3.1+4"

[[FileIO]]
deps = ["Pkg", "Requires", "UUIDs"]
git-tree-sha1 = "256d8e6188f3f1ebfa1a5d17e072a0efafa8c5bf"
uuid = "5789e2e9-d7fb-5bc7-8068-2c6fae9b9549"
version = "1.10.1"

[[FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "335bfdceacc84c5cdf16aadc768aa5ddfc5383cc"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.4"

[[Fontconfig_jll]]
deps = ["Artifacts", "Bzip2_jll", "Expat_jll", "FreeType2_jll", "JLLWrappers", "Libdl", "Libuuid_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "35895cf184ceaab11fd778b4590144034a167a2f"
uuid = "a3f928ae-7b40-5064-980b-68af3947d34b"
version = "2.13.1+14"

[[Formatting]]
deps = ["Printf"]
git-tree-sha1 = "8339d61043228fdd3eb658d86c926cb282ae72a8"
uuid = "59287772-0a20-5a39-b81b-1366585eb4c0"
version = "0.4.2"

[[FreeType2_jll]]
deps = ["Artifacts", "Bzip2_jll", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "cbd58c9deb1d304f5a245a0b7eb841a2560cfec6"
uuid = "d7e528f0-a631-5988-bf34-fe36492bcfd7"
version = "2.10.1+5"

[[FriBidi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "aa31987c2ba8704e23c6c8ba8a4f769d5d7e4f91"
uuid = "559328eb-81f9-559d-9380-de523a88c83c"
version = "1.0.10+0"

[[GLFW_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libglvnd_jll", "Pkg", "Xorg_libXcursor_jll", "Xorg_libXi_jll", "Xorg_libXinerama_jll", "Xorg_libXrandr_jll"]
git-tree-sha1 = "0c603255764a1fa0b61752d2bec14cfbd18f7fe8"
uuid = "0656b61e-2033-5cc2-a64a-77c0f6c09b89"
version = "3.3.5+1"

[[GR]]
deps = ["Base64", "DelimitedFiles", "GR_jll", "HTTP", "JSON", "Libdl", "LinearAlgebra", "Pkg", "Printf", "Random", "Serialization", "Sockets", "Test", "UUIDs"]
git-tree-sha1 = "182da592436e287758ded5be6e32c406de3a2e47"
uuid = "28b8d3ca-fb5f-59d9-8090-bfdbd6d07a71"
version = "0.58.1"

[[GR_jll]]
deps = ["Artifacts", "Bzip2_jll", "Cairo_jll", "FFMPEG_jll", "Fontconfig_jll", "GLFW_jll", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Libtiff_jll", "Pixman_jll", "Pkg", "Qt5Base_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "d59e8320c2747553788e4fc42231489cc602fa50"
uuid = "d2c73de3-f751-5644-a686-071e5b155ba9"
version = "0.58.1+0"

[[GeometryBasics]]
deps = ["EarCut_jll", "IterTools", "LinearAlgebra", "StaticArrays", "StructArrays", "Tables"]
git-tree-sha1 = "15ff9a14b9e1218958d3530cc288cf31465d9ae2"
uuid = "5c1252a2-5f33-56bf-86c9-59e7332b4326"
version = "0.3.13"

[[GeometryTypes]]
deps = ["ColorTypes", "FixedPointNumbers", "LinearAlgebra", "StaticArrays"]
git-tree-sha1 = "07194161fe4e181c6bf51ef2e329ec4e7d050fc4"
uuid = "4d00f742-c7ba-57c2-abde-4428a4b178cb"
version = "0.8.4"

[[Gettext_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Libiconv_jll", "Pkg", "XML2_jll"]
git-tree-sha1 = "9b02998aba7bf074d14de89f9d37ca24a1a0b046"
uuid = "78b55507-aeef-58d4-861c-77aaff3498b1"
version = "0.21.0+0"

[[Glib_jll]]
deps = ["Artifacts", "Gettext_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Libiconv_jll", "Libmount_jll", "PCRE_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "a32d672ac2c967f3deb8a81d828afc739c838a06"
uuid = "7746bdde-850d-59dc-9ae8-88ece973131d"
version = "2.68.3+2"

[[GraphRecipes]]
deps = ["AbstractTrees", "GeometryTypes", "InteractiveUtils", "Interpolations", "LightGraphs", "LinearAlgebra", "NaNMath", "NetworkLayout", "PlotUtils", "RecipesBase", "SparseArrays", "Statistics"]
git-tree-sha1 = "7269dc06b8cd8d16fc2b1756cf7f41901bbc3c52"
uuid = "bd48cda9-67a9-57be-86fa-5b3c104eda73"
version = "0.5.7"

[[Graphics]]
deps = ["Colors", "LinearAlgebra", "NaNMath"]
git-tree-sha1 = "2c1cf4df419938ece72de17f368a021ee162762e"
uuid = "a2bd30eb-e257-5431-a919-1863eab51364"
version = "1.1.0"

[[Graphite2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "344bf40dcab1073aca04aa0df4fb092f920e4011"
uuid = "3b182d85-2403-5c21-9c21-1e1f0cc25472"
version = "1.3.14+0"

[[Grisu]]
git-tree-sha1 = "53bb909d1151e57e2484c3d1b53e19552b887fb2"
uuid = "42e2da0e-8278-4e71-bc24-59509adca0fe"
version = "1.0.2"

[[HTTP]]
deps = ["Base64", "Dates", "IniFile", "MbedTLS", "Sockets"]
git-tree-sha1 = "c7ec02c4c6a039a98a15f955462cd7aea5df4508"
uuid = "cd3eb016-35fb-5094-929b-558a96fad6f3"
version = "0.8.19"

[[HarfBuzz_jll]]
deps = ["Artifacts", "Cairo_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "Graphite2_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Pkg"]
git-tree-sha1 = "129acf094d168394e80ee1dc4bc06ec835e510a3"
uuid = "2e76f6c2-a576-52d4-95c1-20adfe4de566"
version = "2.8.1+1"

[[ImageCore]]
deps = ["AbstractFFTs", "ColorVectorSpace", "Colors", "FixedPointNumbers", "Graphics", "MappedArrays", "MosaicViews", "OffsetArrays", "PaddedViews", "Reexport"]
git-tree-sha1 = "75f7fea2b3601b58f24ee83617b528e57160cbfd"
uuid = "a09fc81d-aa75-5fe9-8630-4744c3626534"
version = "0.9.1"

[[ImageMagick]]
deps = ["FileIO", "ImageCore", "ImageMagick_jll", "InteractiveUtils", "Libdl", "Pkg", "Random"]
git-tree-sha1 = "5bc1cb62e0c5f1005868358db0692c994c3a13c6"
uuid = "6218d12a-5da1-5696-b52f-db25d2ecc6d1"
version = "1.2.1"

[[ImageMagick_jll]]
deps = ["JpegTurbo_jll", "Libdl", "Libtiff_jll", "Pkg", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "1c0a2295cca535fabaf2029062912591e9b61987"
uuid = "c73af94c-d91f-53ed-93a7-00f77d67a9d7"
version = "6.9.10-12+3"

[[Inflate]]
git-tree-sha1 = "f5fc07d4e706b84f72d54eedcc1c13d92fb0871c"
uuid = "d25df0c9-e2be-5dd7-82c8-3ad0b3e990b9"
version = "0.1.2"

[[IniFile]]
deps = ["Test"]
git-tree-sha1 = "098e4d2c533924c921f9f9847274f2ad89e018b8"
uuid = "83e8ac13-25f8-5344-8a64-a9f2b223428f"
version = "0.5.0"

[[InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[Interpolations]]
deps = ["AxisAlgorithms", "ChainRulesCore", "LinearAlgebra", "OffsetArrays", "Random", "Ratios", "Requires", "SharedArrays", "SparseArrays", "StaticArrays", "WoodburyMatrices"]
git-tree-sha1 = "61aa005707ea2cebf47c8d780da8dc9bc4e0c512"
uuid = "a98d9a8b-a2ab-59e6-89dd-64a1c18fca59"
version = "0.13.4"

[[IrrationalConstants]]
git-tree-sha1 = "f76424439413893a832026ca355fe273e93bce94"
uuid = "92d709cd-6900-40b7-9082-c6be49f344b6"
version = "0.1.0"

[[IterTools]]
git-tree-sha1 = "05110a2ab1fc5f932622ffea2a003221f4782c18"
uuid = "c8e1da08-722c-5040-9ed9-7db0dc04731e"
version = "1.3.0"

[[IteratorInterfaceExtensions]]
git-tree-sha1 = "a3f24677c21f5bbe9d2a714f95dcd58337fb2856"
uuid = "82899510-4779-5014-852e-03e436cf321d"
version = "1.0.0"

[[JLLWrappers]]
deps = ["Preferences"]
git-tree-sha1 = "642a199af8b68253517b80bd3bfd17eb4e84df6e"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.3.0"

[[JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "8076680b162ada2a031f707ac7b4953e30667a37"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.2"

[[JpegTurbo_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "d735490ac75c5cb9f1b00d8b5509c11984dc6943"
uuid = "aacddb02-875f-59d6-b918-886e6ef4fbf8"
version = "2.1.0+0"

[[Juno]]
deps = ["Base64", "Logging", "Media", "Profile"]
git-tree-sha1 = "07cb43290a840908a771552911a6274bc6c072c7"
uuid = "e5e0dc1b-0480-54bc-9374-aad01c23163d"
version = "0.8.4"

[[Kroki]]
deps = ["Base64", "CodecZlib", "DocStringExtensions", "HTTP"]
git-tree-sha1 = "1f0c3d257c94012f79d0381914460b2339fe1be9"
uuid = "b3565e16-c1f2-4fe9-b4ab-221c88942068"
version = "0.1.0"

[[LAME_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "f6250b16881adf048549549fba48b1161acdac8c"
uuid = "c1c5ebd0-6772-5130-a774-d5fcae4a789d"
version = "3.100.1+0"

[[LZO_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "e5b909bcf985c5e2605737d2ce278ed791b89be6"
uuid = "dd4b983a-f0e5-5f8d-a1b7-129d4a5fb1ac"
version = "2.10.1+0"

[[LaTeXStrings]]
git-tree-sha1 = "c7f1c695e06c01b95a67f0cd1d34994f3e7db104"
uuid = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
version = "1.2.1"

[[Latexify]]
deps = ["Formatting", "InteractiveUtils", "LaTeXStrings", "MacroTools", "Markdown", "Printf", "Requires"]
git-tree-sha1 = "a4b12a1bd2ebade87891ab7e36fdbce582301a92"
uuid = "23fbe1c1-3f47-55db-b15f-69d7ec21a316"
version = "0.15.6"

[[LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"

[[LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"

[[LibGit2]]
deps = ["Base64", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"

[[LibVPX_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "12ee7e23fa4d18361e7c2cde8f8337d4c3101bc7"
uuid = "dd192d2f-8180-539f-9fb4-cc70b1dcf69a"
version = "1.10.0+0"

[[Libcroco_jll]]
deps = ["Artifacts", "Glib_jll", "JLLWrappers", "Libdl", "Pkg", "XML2_jll"]
git-tree-sha1 = "a8e3b1b67458c8933992b95db9c4b37865906e3f"
uuid = "57eb2189-7eb1-52c8-ac0e-99495f550b14"
version = "0.6.13+2"

[[Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[Libffi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "0b4a5d71f3e5200a7dff793393e09dfc2d874290"
uuid = "e9f186c6-92d2-5b65-8a66-fee21dc1b490"
version = "3.2.2+1"

[[Libgcrypt_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libgpg_error_jll", "Pkg"]
git-tree-sha1 = "64613c82a59c120435c067c2b809fc61cf5166ae"
uuid = "d4300ac3-e22c-5743-9152-c294e39db1e4"
version = "1.8.7+0"

[[Libglvnd_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll", "Xorg_libXext_jll"]
git-tree-sha1 = "7739f837d6447403596a75d19ed01fd08d6f56bf"
uuid = "7e76a0d4-f3c7-5321-8279-8d96eeed0f29"
version = "1.3.0+3"

[[Libgpg_error_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "c333716e46366857753e273ce6a69ee0945a6db9"
uuid = "7add5ba3-2f88-524e-9cd5-f83b8a55f7b8"
version = "1.42.0+0"

[[Libiconv_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "42b62845d70a619f063a7da093d995ec8e15e778"
uuid = "94ce4f54-9a6c-5748-9c1c-f9c7231a4531"
version = "1.16.1+1"

[[Libmount_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "9c30530bf0effd46e15e0fdcf2b8636e78cbbd73"
uuid = "4b2f31a3-9ecc-558c-b454-b3730dcb73e9"
version = "2.35.0+0"

[[Librsvg_jll]]
deps = ["Artifacts", "JLLWrappers", "Libcroco_jll", "Libdl", "Pango_jll", "Pkg", "gdk_pixbuf_jll"]
git-tree-sha1 = "af3e6dc6747e53a0236fbad80b37e3269cf66a9f"
uuid = "925c91fb-5dd6-59dd-8e8c-345e74382d89"
version = "2.42.2+3"

[[Libtiff_jll]]
deps = ["Artifacts", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Pkg", "Zlib_jll", "Zstd_jll"]
git-tree-sha1 = "340e257aada13f95f98ee352d316c3bed37c8ab9"
uuid = "89763e89-9b03-5906-acba-b20f662cd828"
version = "4.3.0+0"

[[Libuuid_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "7f3efec06033682db852f8b3bc3c1d2b0a0ab066"
uuid = "38a345b3-de98-5d2b-a5d3-14cd9215e700"
version = "2.36.0+0"

[[LightGraphs]]
deps = ["ArnoldiMethod", "DataStructures", "Distributed", "Inflate", "LinearAlgebra", "Random", "SharedArrays", "SimpleTraits", "SparseArrays", "Statistics"]
git-tree-sha1 = "432428df5f360964040ed60418dd5601ecd240b6"
uuid = "093fc24a-ae57-5d10-9952-331d41423f4d"
version = "1.3.5"

[[LinearAlgebra]]
deps = ["Libdl"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[LogExpFunctions]]
deps = ["DocStringExtensions", "IrrationalConstants", "LinearAlgebra"]
git-tree-sha1 = "3d682c07e6dd250ed082f883dc88aee7996bf2cc"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "0.3.0"

[[Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[Luxor]]
deps = ["Base64", "Cairo", "Colors", "Dates", "FFMPEG", "FileIO", "ImageMagick", "Juno", "QuartzImageIO", "Random", "Rsvg"]
git-tree-sha1 = "67d44e433fc66e4ee584c7e06dc30bf1d7226aab"
uuid = "ae8d54c2-7ccd-5906-9d76-62fc9837b5bc"
version = "2.14.0"

[[MacroTools]]
deps = ["Markdown", "Random"]
git-tree-sha1 = "0fb723cd8c45858c22169b2e42269e53271a6df7"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.7"

[[MappedArrays]]
git-tree-sha1 = "e8b359ef06ec72e8c030463fe02efe5527ee5142"
uuid = "dbb5928d-eab1-5f90-85c2-b9b0edb7c900"
version = "0.4.1"

[[Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[MbedTLS]]
deps = ["Dates", "MbedTLS_jll", "Random", "Sockets"]
git-tree-sha1 = "1c38e51c3d08ef2278062ebceade0e46cefc96fe"
uuid = "739be429-bea8-5141-9913-cc70e7f3736d"
version = "1.0.3"

[[MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"

[[Measures]]
git-tree-sha1 = "e498ddeee6f9fdb4551ce855a46f54dbd900245f"
uuid = "442fdcdd-2543-5da2-b0f3-8c86c306513e"
version = "0.3.1"

[[Media]]
deps = ["MacroTools", "Test"]
git-tree-sha1 = "75a54abd10709c01f1b86b84ec225d26e840ed58"
uuid = "e89f7d12-3494-54d1-8411-f7d8b9ae1f27"
version = "0.5.0"

[[Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "4ea90bd5d3985ae1f9a908bd4500ae88921c5ce7"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.0.0"

[[Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[MosaicViews]]
deps = ["MappedArrays", "OffsetArrays", "PaddedViews", "StackViews"]
git-tree-sha1 = "b34e3bc3ca7c94914418637cb10cc4d1d80d877d"
uuid = "e94cdb99-869f-56ef-bcf0-1ae2bcbe0389"
version = "0.3.3"

[[MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"

[[NaNMath]]
git-tree-sha1 = "bfe47e760d60b82b66b61d2d44128b62e3a369fb"
uuid = "77ba4419-2d1f-58cd-9bb1-8ffee604a2e3"
version = "0.3.5"

[[NetworkLayout]]
deps = ["GeometryBasics", "LinearAlgebra", "Random", "Requires", "SparseArrays"]
git-tree-sha1 = "76bbbe01d2e582213e656688e63707d94aaadd15"
uuid = "46757867-2c16-5918-afeb-47bfcb05e46a"
version = "0.4.0"

[[NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"

[[OffsetArrays]]
deps = ["Adapt"]
git-tree-sha1 = "c0f4a4836e5f3e0763243b8324200af6d0e0f90c"
uuid = "6fe1bfb0-de20-5000-8ca7-80f57d26f881"
version = "1.10.5"

[[Ogg_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "887579a3eb005446d514ab7aeac5d1d027658b8f"
uuid = "e7412a2a-1a6e-54c0-be00-318e2571c051"
version = "1.3.5+1"

[[OpenSSL_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "15003dcb7d8db3c6c857fda14891a539a8f2705a"
uuid = "458c3c95-2e84-50aa-8efc-19380b2a3a95"
version = "1.1.10+0"

[[OpenSpecFun_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "13652491f6856acfd2db29360e1bbcd4565d04f1"
uuid = "efe28fd5-8261-553b-a9e1-b2916fc3738e"
version = "0.5.5+0"

[[Opus_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "51a08fb14ec28da2ec7a927c4337e4332c2a4720"
uuid = "91d4177d-7536-5919-b921-800302f37372"
version = "1.3.2+0"

[[OrderedCollections]]
git-tree-sha1 = "85f8e6578bf1f9ee0d11e7bb1b1456435479d47c"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.4.1"

[[PCRE_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "b2a7af664e098055a7529ad1a900ded962bca488"
uuid = "2f80f16e-611a-54ab-bc61-aa92de5b98fc"
version = "8.44.0+0"

[[PaddedViews]]
deps = ["OffsetArrays"]
git-tree-sha1 = "646eed6f6a5d8df6708f15ea7e02a7a2c4fe4800"
uuid = "5432bcbf-9aad-5242-b902-cca2824c8663"
version = "0.5.10"

[[Pango_jll]]
deps = ["Artifacts", "Cairo_jll", "Fontconfig_jll", "FreeType2_jll", "FriBidi_jll", "Glib_jll", "HarfBuzz_jll", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "9a336dee51d20d1ed890c4a8dca636e86e2b76ca"
uuid = "36c8627f-9965-5494-a995-c6b170f724f3"
version = "1.42.4+10"

[[Parsers]]
deps = ["Dates"]
git-tree-sha1 = "477bf42b4d1496b454c10cce46645bb5b8a0cf2c"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.0.2"

[[Pixman_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "b4f5d02549a10e20780a24fce72bea96b6329e29"
uuid = "30392449-352a-5448-841d-b1acce4e97dc"
version = "0.40.1+0"

[[Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"

[[PlotThemes]]
deps = ["PlotUtils", "Requires", "Statistics"]
git-tree-sha1 = "a3a964ce9dc7898193536002a6dd892b1b5a6f1d"
uuid = "ccf2f8ad-2431-5c83-bf29-c5338b663b6a"
version = "2.0.1"

[[PlotUtils]]
deps = ["ColorSchemes", "Colors", "Dates", "Printf", "Random", "Reexport", "Statistics"]
git-tree-sha1 = "501c20a63a34ac1d015d5304da0e645f42d91c9f"
uuid = "995b91a9-d308-5afd-9ec6-746e21dbc043"
version = "1.0.11"

[[Plots]]
deps = ["Base64", "Contour", "Dates", "FFMPEG", "FixedPointNumbers", "GR", "GeometryBasics", "JSON", "Latexify", "LinearAlgebra", "Measures", "NaNMath", "PlotThemes", "PlotUtils", "Printf", "REPL", "Random", "RecipesBase", "RecipesPipeline", "Reexport", "Requires", "Scratch", "Showoff", "SparseArrays", "Statistics", "StatsBase", "UUIDs"]
git-tree-sha1 = "e39bea10478c6aff5495ab522517fae5134b40e3"
uuid = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
version = "1.20.0"

[[PlutoUI]]
deps = ["Base64", "Dates", "InteractiveUtils", "JSON", "Logging", "Markdown", "Random", "Reexport", "Suppressor"]
git-tree-sha1 = "44e225d5837e2a2345e69a1d1e01ac2443ff9fcb"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.9"

[[Preferences]]
deps = ["TOML"]
git-tree-sha1 = "00cfd92944ca9c760982747e9a1d0d5d86ab1e5a"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.2.2"

[[Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[Profile]]
deps = ["Printf"]
uuid = "9abbd945-dff8-562f-b5e8-e1ebf5ef1b79"

[[Qt5Base_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Fontconfig_jll", "Glib_jll", "JLLWrappers", "Libdl", "Libglvnd_jll", "OpenSSL_jll", "Pkg", "Xorg_libXext_jll", "Xorg_libxcb_jll", "Xorg_xcb_util_image_jll", "Xorg_xcb_util_keysyms_jll", "Xorg_xcb_util_renderutil_jll", "Xorg_xcb_util_wm_jll", "Zlib_jll", "xkbcommon_jll"]
git-tree-sha1 = "ad368663a5e20dbb8d6dc2fddeefe4dae0781ae8"
uuid = "ea2cea3b-5b76-57ae-a6ef-0a8af62496e1"
version = "5.15.3+0"

[[QuartzImageIO]]
deps = ["FileIO", "ImageCore", "Libdl"]
git-tree-sha1 = "16de3b880ffdfbc8fc6707383c00a2e076bb0221"
uuid = "dca85d43-d64c-5e67-8c65-017450d5d020"
version = "0.7.4"

[[REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[Random]]
deps = ["Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[Ratios]]
deps = ["Requires"]
git-tree-sha1 = "7dff99fbc740e2f8228c6878e2aad6d7c2678098"
uuid = "c84ed2f1-dad5-54f0-aa8e-dbefe2724439"
version = "0.4.1"

[[RecipesBase]]
git-tree-sha1 = "b3fb709f3c97bfc6e948be68beeecb55a0b340ae"
uuid = "3cdcf5f2-1ef4-517c-9805-6587b60abb01"
version = "1.1.1"

[[RecipesPipeline]]
deps = ["Dates", "NaNMath", "PlotUtils", "RecipesBase"]
git-tree-sha1 = "2a7a2469ed5d94a98dea0e85c46fa653d76be0cd"
uuid = "01d81517-befc-4cb6-b9ec-a95719d0359c"
version = "0.3.4"

[[Reexport]]
git-tree-sha1 = "5f6c21241f0f655da3952fd60aa18477cf96c220"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.1.0"

[[Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "4036a3bd08ac7e968e27c203d45f5fff15020621"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.1.3"

[[Rsvg]]
deps = ["Cairo", "Glib_jll", "Librsvg_jll"]
git-tree-sha1 = "3d3dc66eb46568fb3a5259034bfc752a0eb0c686"
uuid = "c4c386cf-5103-5370-be45-f3a111cca3b8"
version = "1.0.0"

[[SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"

[[Scratch]]
deps = ["Dates"]
git-tree-sha1 = "0b4b7f1393cff97c33891da2a0bf69c6ed241fda"
uuid = "6c6a2e73-6563-6170-7368-637461726353"
version = "1.1.0"

[[Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[SharedArrays]]
deps = ["Distributed", "Mmap", "Random", "Serialization"]
uuid = "1a1011a3-84de-559e-8e89-a11a2f7dc383"

[[Showoff]]
deps = ["Dates", "Grisu"]
git-tree-sha1 = "91eddf657aca81df9ae6ceb20b959ae5653ad1de"
uuid = "992d4aef-0814-514b-bc4d-f2e9a6c4116f"
version = "1.0.3"

[[SimpleTraits]]
deps = ["InteractiveUtils", "MacroTools"]
git-tree-sha1 = "5d7e3f4e11935503d3ecaf7186eac40602e7d231"
uuid = "699a6c99-e7fa-54fc-8d76-47d257e15c1d"
version = "0.9.4"

[[Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[SortingAlgorithms]]
deps = ["DataStructures"]
git-tree-sha1 = "b3363d7460f7d098ca0912c69b082f75625d7508"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "1.0.1"

[[SparseArrays]]
deps = ["LinearAlgebra", "Random"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[SpecialFunctions]]
deps = ["ChainRulesCore", "LogExpFunctions", "OpenSpecFun_jll"]
git-tree-sha1 = "a322a9493e49c5f3a10b50df3aedaf1cdb3244b7"
uuid = "276daf66-3868-5448-9aa4-cd146d93841b"
version = "1.6.1"

[[StackViews]]
deps = ["OffsetArrays"]
git-tree-sha1 = "46e589465204cd0c08b4bd97385e4fa79a0c770c"
uuid = "cae243ae-269e-4f55-b966-ac2d0dc13c15"
version = "0.1.1"

[[StaticArrays]]
deps = ["LinearAlgebra", "Random", "Statistics"]
git-tree-sha1 = "3240808c6d463ac46f1c1cd7638375cd22abbccb"
uuid = "90137ffa-7385-5640-81b9-e52037218182"
version = "1.2.12"

[[Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[StatsAPI]]
git-tree-sha1 = "1958272568dc176a1d881acb797beb909c785510"
uuid = "82ae8749-77ed-4fe6-ae5f-f523153014b0"
version = "1.0.0"

[[StatsBase]]
deps = ["DataAPI", "DataStructures", "LinearAlgebra", "Missings", "Printf", "Random", "SortingAlgorithms", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "fed1ec1e65749c4d96fc20dd13bea72b55457e62"
uuid = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
version = "0.33.9"

[[StructArrays]]
deps = ["Adapt", "DataAPI", "StaticArrays", "Tables"]
git-tree-sha1 = "000e168f5cc9aded17b6999a560b7c11dda69095"
uuid = "09ab397b-f2b6-538f-b94a-2f83cf4a842a"
version = "0.6.0"

[[Suppressor]]
git-tree-sha1 = "a819d77f31f83e5792a76081eee1ea6342ab8787"
uuid = "fd094767-a336-5f1f-9728-57cf17d0bbfb"
version = "0.2.0"

[[TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"

[[TableTraits]]
deps = ["IteratorInterfaceExtensions"]
git-tree-sha1 = "c06b2f539df1c6efa794486abfb6ed2022561a39"
uuid = "3783bdb8-4a98-5b6b-af9a-565f29a5fe9c"
version = "1.0.1"

[[Tables]]
deps = ["DataAPI", "DataValueInterfaces", "IteratorInterfaceExtensions", "LinearAlgebra", "TableTraits", "Test"]
git-tree-sha1 = "d0c690d37c73aeb5ca063056283fde5585a41710"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "1.5.0"

[[Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"

[[TensorCore]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "1feb45f88d133a655e001435632f019a9a1bcdb6"
uuid = "62fd8b95-f654-4bbd-a8a5-9c27f68ccd50"
version = "0.1.1"

[[Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[TranscodingStreams]]
deps = ["Random", "Test"]
git-tree-sha1 = "216b95ea110b5972db65aa90f88d8d89dcb8851c"
uuid = "3bb67fe8-82b1-5028-8e26-92a6c54297fa"
version = "0.9.6"

[[UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[Wayland_jll]]
deps = ["Artifacts", "Expat_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Pkg", "XML2_jll"]
git-tree-sha1 = "3e61f0b86f90dacb0bc0e73a0c5a83f6a8636e23"
uuid = "a2964d1f-97da-50d4-b82a-358c7fce9d89"
version = "1.19.0+0"

[[Wayland_protocols_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Wayland_jll"]
git-tree-sha1 = "2839f1c1296940218e35df0bbb220f2a79686670"
uuid = "2381bf8a-dfd0-557d-9999-79630e7b1b91"
version = "1.18.0+4"

[[WoodburyMatrices]]
deps = ["LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "59e2ad8fd1591ea019a5259bd012d7aee15f995c"
uuid = "efce3f68-66dc-5838-9240-27a6d6f5f9b6"
version = "0.5.3"

[[XML2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libiconv_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "1acf5bdf07aa0907e0a37d3718bb88d4b687b74a"
uuid = "02c8fc9c-b97f-50b9-bbe4-9be30ff0a78a"
version = "2.9.12+0"

[[XSLT_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libgcrypt_jll", "Libgpg_error_jll", "Libiconv_jll", "Pkg", "XML2_jll", "Zlib_jll"]
git-tree-sha1 = "91844873c4085240b95e795f692c4cec4d805f8a"
uuid = "aed1982a-8fda-507f-9586-7b0439959a61"
version = "1.1.34+0"

[[Xorg_libX11_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libxcb_jll", "Xorg_xtrans_jll"]
git-tree-sha1 = "5be649d550f3f4b95308bf0183b82e2582876527"
uuid = "4f6342f7-b3d2-589e-9d20-edeb45f2b2bc"
version = "1.6.9+4"

[[Xorg_libXau_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4e490d5c960c314f33885790ed410ff3a94ce67e"
uuid = "0c0b7dd1-d40b-584c-a123-a41640f87eec"
version = "1.0.9+4"

[[Xorg_libXcursor_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXfixes_jll", "Xorg_libXrender_jll"]
git-tree-sha1 = "12e0eb3bc634fa2080c1c37fccf56f7c22989afd"
uuid = "935fb764-8cf2-53bf-bb30-45bb1f8bf724"
version = "1.2.0+4"

[[Xorg_libXdmcp_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4fe47bd2247248125c428978740e18a681372dd4"
uuid = "a3789734-cfe1-5b06-b2d0-1dd0d9d62d05"
version = "1.1.3+4"

[[Xorg_libXext_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "b7c0aa8c376b31e4852b360222848637f481f8c3"
uuid = "1082639a-0dae-5f34-9b06-72781eeb8cb3"
version = "1.3.4+4"

[[Xorg_libXfixes_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "0e0dc7431e7a0587559f9294aeec269471c991a4"
uuid = "d091e8ba-531a-589c-9de9-94069b037ed8"
version = "5.0.3+4"

[[Xorg_libXi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXext_jll", "Xorg_libXfixes_jll"]
git-tree-sha1 = "89b52bc2160aadc84d707093930ef0bffa641246"
uuid = "a51aa0fd-4e3c-5386-b890-e753decda492"
version = "1.7.10+4"

[[Xorg_libXinerama_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXext_jll"]
git-tree-sha1 = "26be8b1c342929259317d8b9f7b53bf2bb73b123"
uuid = "d1454406-59df-5ea1-beac-c340f2130bc3"
version = "1.1.4+4"

[[Xorg_libXrandr_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXext_jll", "Xorg_libXrender_jll"]
git-tree-sha1 = "34cea83cb726fb58f325887bf0612c6b3fb17631"
uuid = "ec84b674-ba8e-5d96-8ba1-2a689ba10484"
version = "1.5.2+4"

[[Xorg_libXrender_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "19560f30fd49f4d4efbe7002a1037f8c43d43b96"
uuid = "ea2f1a96-1ddc-540d-b46f-429655e07cfa"
version = "0.9.10+4"

[[Xorg_libpthread_stubs_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "6783737e45d3c59a4a4c4091f5f88cdcf0908cbb"
uuid = "14d82f49-176c-5ed1-bb49-ad3f5cbd8c74"
version = "0.1.0+3"

[[Xorg_libxcb_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "XSLT_jll", "Xorg_libXau_jll", "Xorg_libXdmcp_jll", "Xorg_libpthread_stubs_jll"]
git-tree-sha1 = "daf17f441228e7a3833846cd048892861cff16d6"
uuid = "c7cfdc94-dc32-55de-ac96-5a1b8d977c5b"
version = "1.13.0+3"

[[Xorg_libxkbfile_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "926af861744212db0eb001d9e40b5d16292080b2"
uuid = "cc61e674-0454-545c-8b26-ed2c68acab7a"
version = "1.1.0+4"

[[Xorg_xcb_util_image_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "0fab0a40349ba1cba2c1da699243396ff8e94b97"
uuid = "12413925-8142-5f55-bb0e-6d7ca50bb09b"
version = "0.4.0+1"

[[Xorg_xcb_util_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libxcb_jll"]
git-tree-sha1 = "e7fd7b2881fa2eaa72717420894d3938177862d1"
uuid = "2def613f-5ad1-5310-b15b-b15d46f528f5"
version = "0.4.0+1"

[[Xorg_xcb_util_keysyms_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "d1151e2c45a544f32441a567d1690e701ec89b00"
uuid = "975044d2-76e6-5fbe-bf08-97ce7c6574c7"
version = "0.4.0+1"

[[Xorg_xcb_util_renderutil_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "dfd7a8f38d4613b6a575253b3174dd991ca6183e"
uuid = "0d47668e-0667-5a69-a72c-f761630bfb7e"
version = "0.3.9+1"

[[Xorg_xcb_util_wm_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "e78d10aab01a4a154142c5006ed44fd9e8e31b67"
uuid = "c22f9ab0-d5fe-5066-847c-f4bb1cd4e361"
version = "0.4.1+1"

[[Xorg_xkbcomp_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libxkbfile_jll"]
git-tree-sha1 = "4bcbf660f6c2e714f87e960a171b119d06ee163b"
uuid = "35661453-b289-5fab-8a00-3d9160c6a3a4"
version = "1.4.2+4"

[[Xorg_xkeyboard_config_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xkbcomp_jll"]
git-tree-sha1 = "5c8424f8a67c3f2209646d4425f3d415fee5931d"
uuid = "33bec58e-1273-512f-9401-5d533626f822"
version = "2.27.0+4"

[[Xorg_xtrans_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "79c31e7844f6ecf779705fbc12146eb190b7d845"
uuid = "c5fb5394-a638-5e4d-96e5-b29de1b5cf10"
version = "1.4.0+3"

[[Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"

[[Zstd_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "cc4bf3fdde8b7e3e9fa0351bdeedba1cf3b7f6e6"
uuid = "3161d3a3-bdf6-5164-811a-617609db77b4"
version = "1.5.0+0"

[[gdk_pixbuf_jll]]
deps = ["Artifacts", "Glib_jll", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Libtiff_jll", "Pkg", "Xorg_libX11_jll", "libpng_jll"]
git-tree-sha1 = "c23323cd30d60941f8c68419a70905d9bdd92808"
uuid = "da03df04-f53b-5353-a52f-6a8b0620ced0"
version = "2.42.6+1"

[[libass_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "acc685bcf777b2202a904cdcb49ad34c2fa1880c"
uuid = "0ac62f75-1d6f-5e53-bd7c-93b484bb37c0"
version = "0.14.0+4"

[[libfdk_aac_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "7a5780a0d9c6864184b3a2eeeb833a0c871f00ab"
uuid = "f638f0a6-7fb0-5443-88ba-1cc74229b280"
version = "0.1.6+4"

[[libpng_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "94d180a6d2b5e55e447e2d27a29ed04fe79eb30c"
uuid = "b53b4c65-9356-5827-b1ea-8c7a1a84506f"
version = "1.6.38+0"

[[libvorbis_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Ogg_jll", "Pkg"]
git-tree-sha1 = "b910cb81ef3fe6e78bf6acee440bda86fd6ae00c"
uuid = "f27f6e37-5d2b-51aa-960f-b287f2bc3b7a"
version = "1.3.7+1"

[[nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"

[[p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"

[[x264_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "d713c1ce4deac133e3334ee12f4adff07f81778f"
uuid = "1270edf5-f2f9-52d2-97e9-ab00b5d0237a"
version = "2020.7.14+2"

[[x265_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "487da2f8f2f0c8ee0e83f39d13037d6bbf0a45ab"
uuid = "dfaa095f-4041-5dcd-9319-2fabd8486b76"
version = "3.0.0+3"

[[xkbcommon_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Wayland_jll", "Wayland_protocols_jll", "Xorg_libxcb_jll", "Xorg_xkeyboard_config_jll"]
git-tree-sha1 = "ece2350174195bb31de1a63bea3a41ae1aa593b6"
uuid = "d8fb68d0-12a3-5cfd-a85a-d49703b185fd"
version = "0.9.1+5"
"""

# ╔═╡ Cell order:
# ╟─6bfb7efa-414e-4123-be13-704d82b67500
# ╟─cba2a2a6-aaa5-4988-b954-552b2b700703
# ╟─56582511-0326-4417-9a95-5ff407b438b6
# ╟─ace787f1-6de8-4f4b-b526-d26a2cc4813f
# ╟─2a0145f6-6c2e-4342-8b34-c7bc0acdb0b2
# ╟─0d77a3e7-2570-4d4d-9443-ace9dd7b8504
# ╠═b9328d7d-1633-4f0a-b812-7cd50937f1d9
# ╟─c8789a4e-89c0-4077-87ae-72cd5b3fd5f2
# ╠═5bbcf948-26a0-428f-bb9e-e4f6fe2aa9b9
# ╟─b8822080-1530-489e-bc7a-e48f6bd1cc8b
# ╠═05bdbbe7-d717-4be3-ba04-5fbfdfc89719
# ╟─873daf1c-9746-4bde-bbec-186a69d4b224
# ╠═74ffabfb-cfe4-4fe7-85be-2dec1d30a378
# ╟─6cc3c476-149d-4119-8be1-8dc3ac8c0c31
# ╠═93b00f2a-7fc7-4a21-8dac-5088279a4569
# ╟─c11df40f-f7ba-42f4-9d67-56e86b1ce409
# ╠═4b35aef8-4c21-4202-a186-a5addc44d2a3
# ╠═8e2709c9-821e-4a33-b638-f4c0e58fd235
# ╠═37157b08-cacf-4a36-b8e6-a84dce79af96
# ╟─737c8c5f-3606-43cd-bf52-5553c3504df1
# ╠═effb7b3e-c129-4a01-a33b-b325d1ffeadb
# ╠═882b9fce-9572-477b-928b-2f7faa383f35
# ╟─18fc0c3b-8d43-4e23-aee8-b0b87566520a
# ╠═9d5bb38c-481c-43e2-b671-63330af82f79
# ╟─1d819b3f-eba6-47ce-bf80-a18fb667ddfd
# ╠═0e0ad0d6-2f67-45a5-9f68-2ebe428813db
# ╟─86744569-a16c-46ea-ac5f-7749e1ee1397
# ╠═2a7cae23-aa3a-425b-be97-e16565bba189
# ╟─7a888d5d-44df-45e0-b2b3-3922dbdecf93
# ╠═289ad30b-056f-46fd-877c-6fb20db81749
# ╠═433d2722-a463-490f-a053-80544b7d6500
# ╟─8f678910-0c5d-4dee-bc43-261f071429c8
# ╠═1492766f-6d10-418d-a41e-d97920adf56c
# ╟─337b4b86-9a9d-4546-854a-ab934381ad1a
# ╠═db200cf8-8d7a-4fa1-9e3a-e86b019d54ef
# ╟─019c256c-516a-44ce-ae0e-ce852699a0aa
# ╠═0e2180ad-fbf5-47d8-afc8-386e7f070e48
# ╟─ae749f60-95dc-4f15-9958-a56c058af938
# ╠═0ae56b35-1568-4585-9f24-64633c100b3d
# ╠═7e942344-cc0e-4c4e-8ddc-a562804bd358
# ╠═aee4e6ff-9dea-4213-b171-535aa0439bb0
# ╠═b08e3688-0b1b-422c-b383-53dad7115c5d
# ╠═8b3217c0-860d-413c-b80d-613c14136535
# ╠═38747f55-51e7-42f3-89db-f53f23b4c608
# ╠═906d8176-7eaf-4803-b8f7-a6c3329877e5
# ╠═177e8e8d-0607-40d2-b1ac-56c53371c2dc
# ╟─af93e7a0-f3e7-4382-b955-a60b9eba9f78
# ╠═5c4e8e12-12bf-4164-abd5-f4ac7a8b9aeb
# ╟─97c16ebc-2bd3-4d8b-bb37-25e3e74e4dec
# ╠═1d713b63-eba5-4cc3-9746-75002b46af72
# ╟─9764ca42-2da7-4751-9d5d-cf96b54031f1
# ╠═4fbcf38d-7065-4fbe-b5e8-ead0bc126b1f
# ╟─6734c935-d5b0-41b3-8ead-20299df899e8
# ╠═5ca3d707-5a34-4834-8709-b429b620d290
# ╟─42bc8e51-2296-4a18-9c00-934043877db6
# ╠═29f8d68a-5407-4cdd-ae20-64f7baf83c30
# ╟─6400ab80-cb5f-47a4-ab97-474827a2e167
# ╠═82853951-f0b0-4706-a1d6-5f1bd285d573
# ╟─e663675d-f69a-4a1e-a0a1-380287d32fd8
# ╠═3a4a726b-2cb1-4510-97db-76f4be50809a
# ╟─a207ec7f-32c8-4263-9a33-b49ca957f80c
# ╠═a1a85b07-3afa-4bb5-971a-645073f3a208
# ╟─721082c5-5eff-41e9-b199-7af5ec890e3b
# ╠═db4eb41d-6751-46d2-9e44-e7dc1c892b4d
# ╟─4238943b-9659-4fe9-b6ca-d94018b0b856
# ╠═fbc1dc24-a493-48a1-ad5f-421b1b777cf1
# ╟─53a07edc-b072-4cfb-9ae3-e90382b90be8
# ╠═4b0dfcba-8435-4a60-9bca-bbc4f8cf1a54
# ╟─a8e82de2-eedb-46ac-bf24-289d3ea32df1
# ╟─6432fe70-1789-4609-bd25-ea4984932981
# ╠═c870418e-307f-44bf-ab8d-9efdf6161a4f
# ╟─8501b399-a74d-4e4c-954a-a556353b9847
# ╠═9054b61c-ae11-4c17-9811-445cd96e034a
# ╟─33c045e1-5b13-46be-9405-3f35d2f15470
# ╟─24b61554-3fba-49b5-ba32-dba7415960de
# ╠═251d98d7-2225-4bc7-b3f0-935fa051dc30
# ╟─e5524dca-0f8d-465f-b79e-71722dd62322
# ╠═56225c1c-2ba7-4bdd-8d1b-6891813182d8
# ╟─0edf57f6-e0e0-48c8-81a6-883cee5e4983
# ╠═f15740a5-c318-429f-b270-f511f86f19a9
# ╟─af24eddc-e056-47ed-96ad-799d12024dbb
# ╠═28aac5cf-fc03-469b-8976-c228779fe969
# ╟─ad122b57-7fa0-42be-81b8-132ed26a6866
# ╠═40920bd0-c398-44f2-b718-677d8ba6a441
# ╟─f890dea4-e520-4697-bd1c-f685f2c3a509
# ╟─219b2396-8ef6-4230-a599-8b8ce4d577ad
# ╟─dcc42c3a-d74a-4505-9360-0dda1e159fb7
# ╠═75954adf-e970-4353-95e3-86d0548e4ad1
# ╠═6b960fe3-480e-4852-be70-3ffe63efe770
# ╟─9155d44b-3600-40f9-8b87-4ea848f3f136
# ╠═cc57b360-10b0-41f3-96d8-85d02314ae0c
# ╟─68e1782b-52ed-4606-a774-a776f9f3a443
# ╠═152e1c21-9f74-49a1-892a-728034975890
# ╟─5861e4b9-fe7a-4fd4-8523-d81d66020b23
# ╠═5d02fd10-3849-4862-b46a-f64604f876aa
# ╟─f896cd78-4331-4c46-af00-45e3e59bc4f1
# ╠═c2420dbd-c559-433f-b1d3-25841a444f6d
# ╠═e2eb656e-dda1-4916-994b-b9df1703ab47
# ╟─045f8edb-0de0-4074-82f6-f947e909c61a
# ╟─dd71ef7b-d7e2-48ed-a397-f78e971a6f47
# ╠═39cf4b15-2999-4a90-8933-0f5f6e736e33
# ╟─4b095876-54fa-4da3-89ea-76f15a1a7299
# ╠═6356184b-e031-44cf-aef1-ae57299ff061
# ╟─a96ed46f-19e3-454f-b894-70b81c6e4928
# ╠═b8c33ed8-4171-4225-b27d-9bb9dbe8f8ed
# ╟─e86a9992-0386-4206-b9d4-99120e754a14
# ╠═5427db44-4010-4d29-b46a-82175971459f
# ╟─f8fd23b4-1bf2-4345-831a-bb3e17a8dbbe
# ╠═5c7512d6-ac5f-4e83-95be-b4fe6c8930ec
# ╟─940e67f8-fcca-402d-b9b2-488f7b7b161a
# ╠═b7da0322-7120-4659-b1e2-a268c58458cf
# ╟─26e3f6fc-41b0-445c-bdee-314720d9fae9
# ╟─f2d51612-2f92-4638-9fe8-cf12512efc05
# ╠═033ee922-46f7-4488-b7ef-4abd0ec24e13
# ╟─c432cee9-2cca-4b47-92c5-e053dc8c62e9
# ╠═6fa42bc1-831f-4ea8-bb10-c8bef8b73a62
# ╟─74503e0c-4d81-4416-8757-945273c8d5cf
# ╠═9279e3eb-7c1f-42e8-a077-859b836e4304
# ╠═8c3ef4ff-fe57-40c4-a999-6f2c3dc02883
# ╟─66beb2f6-7f31-49e2-877c-d6f18e3b4453
# ╠═8fafde27-504a-43b9-ad4f-db6561784d1e
# ╟─39d9c535-7e07-4e6e-9337-e7da36764509
# ╠═4d8aee6b-cc05-4d67-9492-32b39f763b03
# ╟─50551abf-44d2-4050-9c1a-c1c0acfe9b8b
# ╠═b95983f9-65fc-4148-9dcf-9db248a5416d
# ╟─89eb9447-6417-4633-8738-fb56b5a7589e
# ╠═e221e01c-2eb0-4b2b-950f-36398edc2aee
# ╟─0d51605a-a0d0-4471-b0f7-5773ae9b480d
# ╠═071b1c6a-9eca-4fb5-9c45-082b6249c191
# ╠═52be65d2-944d-4788-8584-0d2a6244d91e
# ╠═23287766-7d08-4740-b180-e55d8f987c56
# ╟─64d51f37-91a1-4a4e-8976-9ab81c7a50a3
# ╠═01d431bc-421e-4e81-adde-5d715acafbb2
# ╟─f5d99600-d281-4de8-8c7c-b4b8ed934eb5
# ╠═e2348d82-005e-458f-8b9b-a8e07e3b14ee
# ╠═86a0442c-a689-4192-95e4-90e30620d584
# ╠═4ae17f1b-37bb-40ca-8202-162a38a8da9c
# ╠═360fef9d-e3fa-4ea9-80d9-978adb5f12c8
# ╟─bbe57268-af9e-41a0-92a5-b9620fcfde45
# ╟─acdaf483-3269-4916-bcbb-6f25a15d32b2
# ╟─054e5c93-8bc7-46df-ae99-6290edff8136
# ╠═5d033a83-2467-4e62-b4a2-e6922720d7a9
# ╠═09f37ea7-dfdc-49a9-9b12-1390f06cca83
# ╟─2f668655-7aa0-4031-9303-c446f6a95808
# ╟─4fe44dfb-c001-4039-be4b-eba67cb73a44
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
