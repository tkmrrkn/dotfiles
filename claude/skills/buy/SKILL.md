---
name: buy
description: Compares products and recommends the one that fits the user's actual use, by building the evaluation criteria from their requirements and reading what buyers actually report instead of trusting star averages. Use this whenever the user is working out what to buy — 「〜を探している」「どれがいい」「比較して」「買い替えたい」「おすすめある？」「〜ってどう？」「安いのないかな」— or names a product or a product category they might purchase, even when they never ask for a comparison and even when they mention only one product. It covers any genre, such as appliances, kitchenware, furniture, PC peripherals, tools, daily goods. It does not cover choosing software libraries, cloud services, or dependencies for a codebase.
---

# Compare products and recommend one

The user is working out what to buy. Build the evaluation criteria from how they will actually use
the thing, gather evidence that survives scrutiny, and recommend what fits — or say plainly that
nothing does.

**Write the entire output in Japanese**, even though this file is written in English.

Argument: $ARGUMENTS

The request may instead sit in the conversation, in which case use that and do not ask for it again.

## What this is for

Supporting a purchase decision. A specification table or a ranking is not the deliverable — the
user can already find those. What they cannot easily get is a judgement that accounts for how they
will use the thing, built on evidence someone actually checked.

Research and report only. Change no files; nothing here needs writing to disk.

## What stays fixed, what changes with each purchase

Keep these fixed, because they are what makes the answer trustworthy rather than merely confident:

- Settle the requirement before choosing products.
- Base the judgement on evidence, and say where each piece came from.
- Hunt for drawbacks and purchase risks as hard as for merits.
- Never let a review average carry a conclusion on its own.
- Weigh sources by what they are good for, and state what you could not find out.
- Keep verified fact, a buyer's subjective impression, and your own inference apart.
- Never present something you did not investigate as though you had.

Decide these fresh for each purchase, because fixing them is what turns a comparison into a
generic ranking:

- Which criteria matter, and how much.
- How price, performance, build quality, durability and convenience rank against each other.
- The hard requirements, and the drawbacks that rule a product out.
- Which sources to consult and how deep to go.
- How many products to compare, and how many to shortlist.

Resist settling on one objective for every purchase — "do not regret it", "maximise quality",
"maximise value for money". Which of those applies is a property of this user and this purchase,
and choosing it for them is how a recommendation ends up answering a question nobody asked.

## Step 1: Pin down the requirement

Work out what the purchase has to satisfy: the purpose, where and how it will be used, the hard
requirements, what they want to be good, the drawbacks they will not accept, and how they think
about price.

Do not ask again for anything the conversation already told you — re-asking reads as not having
listened. Where something is missing but a reasonable assumption lets the work continue, state the
assumption and carry on. Save questions for gaps that would change the answer, because a question
the user has to stop and answer costs them more than a stated assumption they can correct in
passing.

## Step 2: Build the evaluation criteria

Pick the criteria that fit this genre and this user. Keep hard requirements separate from things
that merely earn credit: failing a hard requirement removes a product, while a weak point on a
credit-earning criterion only lowers it.

- Respect the priorities the user stated, and do not invent ones they did not.
- Where requirements genuinely conflict, show the trade-off rather than quietly resolving it.
- Skip invented composite scores. A number like "total 87 points" implies a weighting you cannot
  defend, and it hides the reasoning the user needs in order to disagree with you.

Then check the criteria against how the user will actually use the thing, and **cancel the credit
that does not apply to them**. Review scores and published rankings aggregate over everybody, so a
product often wins on a strength this user will never touch — easy one-handed operation for someone
who will leave it in place, portability for someone who will not carry it. When a ranking's margin
comes from such a strength, say so and discount it. Carrying that credit through unexamined is the
most common way a well-reviewed product ends up recommended to the wrong person.

## Step 3: Find out where the evidence lives

Before collecting candidates, work out where substantive evidence for *this* kind of product sits.
It varies sharply by genre: for some categories a price-comparison site carries hundreds of detailed
reviews, while for others the same site has three; some genres get independent side-by-side testing,
others have nothing but retailer star ratings and enthusiast forums. A search or two spent on where
people actually review this pays for itself, because everything downstream inherits the quality of
the sources.

Judge a source before leaning on it:

- **Does the volume support a conclusion?** An average over three reviews is an anecdote with a
  decimal point. Always carry the count next to the score so the reader can weigh it too.
- **Were the ratings paid for?** Listings advertising a bonus, campaign, or gift in exchange for a
  review collect a selected sample, and their averages run high for that reason alone. Look for the
  same product somewhere no bonus is attached, and compare.
- **Was the reviewer compensated?** Sponsored articles and supplied units can be honest and still
  omit what the maker would rather not see written down.
- **Does the review match the product?** Model numbers, generations and sizes share listing pages.
  Enthusiastic praise for last year's version says little about this one.
- **Is there independent measurement?** Testing that puts many products through one procedure
  outranks any single opinion, the maker's included. Look for it early; when it exists it reshapes
  the whole comparison.

Sources are not interchangeable. Maker documentation settles specifications, buyers settle what
living with the thing is like, independent testing settles comparisons between products. Using one
to do another's job is where confident wrong answers come from.

## Step 4: Collect candidates, then narrow

Gather candidates first, then cut them on fit and on the strength of the evidence.

- Remove what fails a hard requirement.
- When you cannot confirm a hard requirement, say it is unconfirmed rather than assuming it holds.
- Do not let brand recognition or search ranking choose the candidates for you; both measure
  marketing spend as much as quality.
- A serious drawback found late is grounds for dropping a product or lowering it, even if it was
  leading.
- More candidates is not the goal. A shortlist investigated deeply beats a long list skimmed.

When one candidate starts looking strong, deliberately research its rivals to the same depth.
Otherwise the early favourite wins on having been studied more, which is not a reason to buy it.

## Step 5: Read the reviews

Treat buyer reviews as primary evidence, and go past the stars into what people wrote.

For both praise and complaints, find out:

- The specific reason behind it, not the sentiment.
- Whether several independent buyers report the same thing — one account is an anecdote, five is a
  pattern.
- The conditions that trigger the problem, and whether this user's conditions match.
- How the product changed over time in use, which is the thing a brand-new purchase cannot tell you.
- Whether it reads as a defective unit or as the design behaving as built. One is replaced; the
  other is what the user will live with.
- How much the problem matters *for this use*. A flaw that is fatal for one buyer is irrelevant to
  another.

Do not count low ratings and stop there. Weigh severity, how reproducible the problem is, how
credible the account is, and whether it bears on this purchase at all.

**A search-result summary is not a review.** Summaries smooth out exactly the specifics that decide
the question — how many months in, under what conditions, whether it was replaced. When you could
not reach the review text, say so and say what that leaves unresolved, rather than letting a summary
stand in for evidence.

Keep three things apart: the review count, the average score, and what you concluded from reading
the text. They have different reliability and the reader needs to see which is which.

Do not drop a product merely for having few reviews or none. Look for other evidence, and let the
uncertainty show in the recommendation instead of silently resolving it.

## Step 6: Read what the warranty excludes

Check the warranty by what it does not cover, not by its length. A long warranty is a strong selling
point precisely because buyers read the number and stop. The failure that actually ends a product's
life is often listed as out of scope — ordinary wear, the surface degrading, cosmetic damage, or
anything the maker can attribute to how it was used. A shorter warranty covering the real failure
mode is worth more than a long one that excludes it. Check too whether the warranty is honoured by
the maker, the importer, or only an authorised seller, since that decides whether it survives buying
from the cheapest shop.

Report price as a range: the list price and what it actually sells for. The gap is often large
enough to change which product wins, and it tells the user where to buy as well as what.

## Step 7: Decide and report

Base the recommendation on this user's requirement and on the evidence you actually gathered. Do not
let an average score, the lowest price, or the biggest number on a spec sheet decide it mechanically
— each of those answers a different question from the one the user asked.

Cover what applies:

- The product you recommend, and why.
- Alternatives that win under a specific condition, with the condition named.
- Products to avoid, and what makes them a bad fit.
- Risks worth understanding before buying.
- What you could not establish, and what it would take to establish it.

If nothing meets the requirement, or the evidence is too thin to choose, say that. A forced winner
is worse than no winner, because the user acts on it believing it was chosen on merit. Where the
requirement itself is the obstacle, say which constraint would have to give.

## Report

Write in Japanese, and structure the report around the decision rather than around your research.
Include, to the extent each applies: the conclusion and the recommended product; the reasoning; a
comparison of the leading candidates; the concrete strengths and weaknesses that came out of the
reviews; serious drawbacks and risks; price and specifications; sources; and the limits of what you
checked.

Choose the form to fit the material — a table when several products differ along the same few axes,
prose when the decision turns on one or two things. Prefer what helps the decision over what fills
the page, and give the reasoning as well as the conclusion, because the user has to be able to
disagree with you.

## Watch for

- Concluding from scores alone. The score is a summary of reasons; the reasons are the evidence.
- Blurring verified fact, a buyer's impression, and your own inference into one confident voice.
- Writing up what you did not check as though you had, or letting a search summary pass for a
  source.
- Letting the first search settle it. Early results reflect marketing reach, so treat them as a
  starting list and keep looking.
- Changing a recommendation silently. When new evidence overturns something you already told the
  user, withdraw the earlier recommendation explicitly and say what changed it; otherwise they
  cannot tell which of your two answers to trust. This is the `[reply-correction]` rule in
  CLAUDE.md, and a comparison that develops over several turns is exactly where it applies.
