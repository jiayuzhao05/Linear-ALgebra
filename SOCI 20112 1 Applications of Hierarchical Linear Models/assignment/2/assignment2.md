**Group notes (current status)**

- **Part A (longitudinal):** Course model is the **3-level quadratic growth** specification using `EG1.sav`–`EG3.sav`, `Year` centered near spring of grade 1, **Black** and **Hispanic** **uncentered** dummies, **White** as the **reference** group (so **do not** add a separate White indicator—omitted category is the benchmark for all ethnic comparisons).
- **Part B, Question 1 (Canvas correction):** There are **three** non-White racial categories in the NELS coding for this homework; **White** is the reference and is **not** listed as a separate intercept/coefficient to interpret.
- **Part B extensions:** A group member also tried **CATHLOC**, **URBAN**, and **SCHSIZE** as level-2 controls; many coefficients became **non-significant**, with similar patterns under other control sets, so the group is keeping that predictor set for the final sector model.
- **Merging workflow:** Combine each member’s sections into one document, then revise as a group.

---

## Part A: Ethnic disparities in mathematics achievement growth and school poverty (`LOWINC`)

**Data:** Chicago elementary school longitudinal files (`EG1.sav`, `EG2.sav`, `EG3.sav`).  
**Outcome:** Math achievement (use the variable specified in lab/Canvas).  
**Predictors:** Time (`Year`, centered as instructed); child-level **Black** (1/0), **Hispanic** (1/0), mutually exclusive; school-level **LOWINC** (% low income) in Questions 6–7.

The sections below give **complete model text and interpretation logic**. Replace bracketed placeholders such as `[paste γ̂]` with values from **your** HLM output.

---

### 1. Model at each level (3-level quadratic growth; White = reference)

**Indexing:** occasion \(t\), child \(i\), school \(j\).  
**\(a\_{tij}\):** `Year` centered at approximately spring of first grade (as in the assignment).  
**Black\(_{ij}\), Hispanic\(_{ij}\):** dummy indicators (0/1), **not** centered. **White** students have both dummies = 0.

#### Level 1 — within child (occasions nested in child)

\[
Y*{tij} = \pi*{0ij} + \pi*{1ij}\, a*{tij} + \pi*{2ij}\, a*{tij}^2 + e\_{tij}
\]

- \(Y\_{tij}\): math achievement at occasion \(t\) for child \(i\) in school \(j\).
- \(\pi*{0ij}\): implied “status” of the growth curve at the time origin (where \(a*{tij}=0\)).
- \(\pi\_{1ij}\): linear growth rate (slope on time).
- \(\pi\_{2ij}\): quadratic curvature (acceleration/deceleration).
- \(e*{tij}\): occasion-level residual, \(e*{tij} \sim N(0,\sigma^2)\) (homoscedastic, uncorrelated across occasions unless your instructor specifies otherwise).

#### Level 2 — between children (within school)

\[
\begin{aligned}
\pi*{0ij} &= \beta*{00j} + \beta*{01j}\,\text{Black}*{ij} + \beta*{02j}\,\text{Hispanic}*{ij} + r*{0ij} \\
\pi*{1ij} &= \beta*{10j} + \beta*{11j}\,\text{Black}_{ij} + \beta_{12j}\,\text{Hispanic}_{ij} + r_{1ij} \\
\pi*{2ij} &= \beta*{20j} + \beta*{21j}\,\text{Black}*{ij} + \beta*{22j}\,\text{Hispanic}*{ij} + r\_{2ij}
\end{aligned}
\]

- **\(r*{0ij}, r*{1ij}, r\_{2ij}\)** are allowed to vary (**child-level random effects**), with a \(3\times 3\) covariance structure among them (as you specify in HLM, e.g. unstructured or as taught in class).
- **Ethnic coefficients** \(\beta*{01j},\beta*{02j},\ldots,\beta\_{22j}\) capture **Black–White** and **Hispanic–White** contrasts on intercept, linear slope, and quadratic terms **relative to the omitted White category**.

#### Level 3 — between schools

Only the **reference (White) “base” growth parameters** for the school carry random effects \(u*{00j}, u*{10j}, u\_{20j}\). Ethnic contrasts are **fixed across schools**:

\[
\begin{aligned}
\beta*{00j} &= \gamma*{000} + u*{00j}, &
\beta*{01j} &= \gamma*{010}, &
\beta*{02j} &= \gamma*{020}, \\
\beta*{10j} &= \gamma*{100} + u*{10j}, &
\beta*{11j} &= \gamma*{110}, &
\beta*{12j} &= \gamma*{120}, \\
\beta*{20j} &= \gamma*{200} + u*{20j}, &
\beta*{21j} &= \gamma*{210}, &
\beta*{22j} &= \gamma\_{220}.
\end{aligned}
\]

- **\(u\_{00j}\):** school-specific deviation for the **White** intercept component \(\gamma\_{000}\).
- **\(u\_{10j}\):** school-specific deviation for the **White** linear slope \(\gamma\_{100}\).
- **\(u\_{20j}\):** school-specific deviation for the **White** quadratic term \(\gamma\_{200}\).
- **\(u\)’s** are mean-zero school random effects with a \(3\times 3\) covariance matrix (per your HLM setup), independent of child effects at the model stage you specify.

**Composite trajectory for each group (for interpretation):**  
For **White** children (\(\text{Black}=\text{Hispanic}=0\)), plugging through gives a school-specific quadratic in time with random child and school deviations on intercept, slope, and curvature. For **Black** students, add \(\gamma*{010},\gamma*{110},\gamma*{210}\) to the corresponding fixed parts; for **Hispanic**, add \(\gamma*{020},\gamma*{120},\gamma*{220}\).

---

### 2. Estimation, fixed effects (\(\gamma\)’s), and ethnic differences in **learning rates**

**Estimation:** Use the procedure required in your lab (e.g. restricted ML / full ML as specified). Center time as instructed; keep **Black** and **Hispanic** uncentered.

**How to interpret fixed coefficients (focus on learning rates):**  
Learning **speed** (instantaneous rate of change at time \(a\)) for a group is

\[
\frac{\partial Y}{\partial a} = \pi_1 + 2\pi_2\, a
\]

At the **average school** and for a given ethnicity, substitute the **fixed** parts:

- **White:** \(\gamma*{100} + 2\gamma*{200}\,a\) (plus child/school random pieces for an individual, not the population-average \(\gamma\) interpretation).
- **Black:** \((\gamma*{100}+\gamma*{110}) + 2(\gamma*{200}+\gamma*{210})\,a\).
- **Hispanic:** \((\gamma*{100}+\gamma*{120}) + 2(\gamma*{200}+\gamma*{220})\,a\).

**Paragraph template (paste estimates and adjust sign/magnitude):**

> At the spring-of-grade-1 time origin, White students’ average implied math level is \(\gamma*{000}\) [report estimate, SE, p]. Black students differ by \(\gamma*{010}\) and Hispanic students by \(\gamma*{020}\) on that same scale [interpret direction and size]. For **linear learning**, White students’ average linear slope is \(\gamma*{100}\). Black students’ **increment** to the linear slope is \(\gamma*{110}\) and Hispanic students’ is \(\gamma*{120}\) [if negative, Black/Hispanic students gain fewer points per year on average than White students at this linear term, holding the quadratic structure; combine with \(\gamma_{210},\gamma_{220}\) when discussing acceleration]. The quadratic terms \(\gamma*{200}\), and the ethnic increments \(\gamma*{210}\) and \(\gamma\_{220}\), indicate whether growth curves bend and whether that bending differs by group; **if** the ethnic slope and curvature terms are jointly small or non-significant, say that **average learning rates** (especially over the observed window) are **similar** after accounting for starting level; **if** they are large, say which group is catching up or falling behind **over time**, not only at baseline.

Replace every \(\gamma\) with your table of **gamma estimates**.

---

### 3. Graph of average trajectories

**What to submit:** A plot of **model-implied mean trajectories** for **White**, **Black**, and **Hispanic** students over the range of centered `Year` in the data (use your software’s fitted fixed-effect trajectory or equivalent).

**Construction (HLM / other):**

1. Fix `Year` → \(a\) on the x-axis from min to max used in the analysis.
2. For each group, compute \(\hat Y(a) = \hat\pi_0 + \hat\pi_1 a + \hat\pi_2 a^2\) using **only fixed components** (population averages), with \((\hat\pi_0,\hat\pi_1,\hat\pi_2)\) set from \(\hat\gamma\)’s for that ethnicity as in the composites above.
3. Overlay three curves; label clearly. **Do not** try to plot “both Black and Hispanic” for the same child—those categories are **mutually exclusive**.

**What to describe:**  
Whether curves **start** at different levels (intercept differences), **diverge or converge** (slope/curvature differences), and whether gaps **widen or narrow** between early and later grades. Tie sentences directly to the signs of \(\gamma*{010},\gamma*{020},\gamma*{110},\gamma*{120},\gamma*{210},\gamma*{220}\).

---

### 4. Allowing only \(u*{00j}, u*{10j}, u\_{20j}\) at level 3 — meaning and assumptions

**Substantive meaning:**  
Schools differ randomly in **where White students’ average trajectory** is located (\(u*{00j}\)), how **fast** they change on average in the linear component (\(u*{10j}\)), and how **curved** that average trajectory is (\(u*{20j}\)). Those school differences **do not** multiply or interact with race in this specification: **Black–White** and **Hispanic–White** gaps on intercept, slope, and curvature are **the same in every school** (purely fixed \(\gamma*{010}\)–\(\gamma\_{220}\)).

**What you assume:**

1. **No random ethnic × school interactions:** You are **not** estimating whether the Black–White achievement gap’s **growth** differs across schools.
2. **Shared school “baseline”** random factors still shift **all** students in the school through \(\beta*{00j},\beta*{10j},\beta\_{20j}\); because those enter every child’s \(\pi\)’s before adding ethnic contrasts, school quality shocks are **common** rather than race-specific in the random part.
3. If reality has **heterogeneous** ethnic gaps across schools, this model **misspecifies** that heterogeneity and can bias or misallocate variance (some true interaction variance may appear in level-2 or level-1 variation or in residuals, depending on the data).

**Bottom line for write-up:**

> We assume that **between-school variability in growth pertains to the reference (White) trajectory**, while **ethnic contrasts are constant across schools**. That simplifies estimation but rules out discovering, for example, that the Hispanic–White slope gap is larger in some schools than others.

---

### 5. 95% plausible value intervals (PVI)

**Clarification:** The printed assignment lists **three** intervals (including a **child-level Hispanic–White gap**). If your instructor’s Canvas note **removed** that middle item, report **only** the first and third below.

**A. Child-level variation in achievement related to White students (typically intercept random effect \(r\_{0ij}\))**  
Let \(\hat\tau*{00}\) be the estimated **standard deviation** of \(r*{0ij}\) for the **random intercept** at level 2 (from your covariance output). A common **95% PVI** for the **child-specific deviation** on \(\pi_0\) is approximately

\[
\text{PVI}_{95}(r_0) \approx \pm 1.96 \times \hat\tau_{00}.
\]

**Interpretation template:**

> For White students in an average school, **95% of the plausible child-level deviations** in **status at the time origin** fall within about \(\pm 1.96\hat\tau\_{00}\) achievement points around that child’s school’s conditional mean trajectory [insert numeric bounds].

\*If your software prints a different parameterization (e.g. total child heterogeneity in composite scores), match the instructor’s term “achievement” to the **specific random effect** they want (usually \(r_0\) for status).

**B. (Optional / only if still required) Child-level Hispanic–White gap**  
Here the **mean gap** at a given growth parameter is **fixed** (e.g. \(\gamma\_{020}\) on \(\pi_0\)); there is **no** random “gap” component unless the model adds one. Many classes therefore ask for a **95% confidence interval** for the **fixed** contrast instead:

\[
\gamma*{020} \pm 1.96 \times SE(\gamma*{020})
\]

and interpret as uncertainty about the **population** Hispanic–White difference at the time origin—not a “plausible value” for a random effect.

**C. School-level variation for White students (random intercept \(u\_{00j}\))**  
With \(\hat\tau*{u0}\) the SD of \(u*{00j}\),

\[
\text{PVI}_{95}(u_0) \approx \pm 1.96 \times \hat\tau_{u0}.
\]

**Interpretation template:**

> **About 95% of schools** have White-students’ **origin status** components that fall within \(\pm 1.96\hat\tau*{u0}\) points of the grand mean \(\gamma*{000}\) [insert numbers].

Repeat the same logic for \(u*{10j}\) and \(u*{20j}\) **only if** the question explicitly asks for those pieces.

---

### 6. Re-estimate with **LOWINC** — does poverty predict a child’s **growth rate**?

**Augmented level-3 model (example — center `LOWINC` only if your assignment/lab says so):**

\[
\begin{aligned}
\beta*{00j} &= \gamma*{000} + \gamma*{001}\,\text{LOWINC}\_j + u*{00j}, \\
\beta*{10j} &= \gamma*{100} + \gamma*{101}\,\text{LOWINC}\_j + u*{10j}, \\
\beta*{20j} &= \gamma*{200} + \gamma*{201}\,\text{LOWINC}\_j + u*{20j}, \\
\beta*{01j} &= \gamma*{010}, \quad
\beta*{02j} &= \gamma*{020}, \quad \ldots \quad \text{(remaining ethnic \(\beta\)’s at L3 fixed like Q1).}
\end{aligned}
\]

**What “predicts growth rate” means here:**  
The **instantaneous** rate still involves \(\pi*1\) and \(\pi_2\). School **LOWINC** enters the models for \(\beta*{10j}\) and \(\beta*{20j}\), so it can affect **both** linear slope and curvature. **Primary coefficient for “growth rate”:** \(\gamma*{101}\) (linear) and, for bending, \(\gamma\_{201}\).

**Template:**

> A one-point increase in **LOWINC** is associated with a \(\gamma*{101}\)-point change in the **average linear math growth rate** for the reference trajectory, controlling for ethnic composition at child level [quote p-value]. Curvature shifts by \(\gamma*{201}\) per unit LOWINC [interpret if significant].

**What to turn in:** Same tables as Q2 but with LOWINC; **interpret only** \(\gamma*{101}\) (and \(\gamma*{201}\) if relevant) plus any **LOWINC** terms that your instructor cares about for level shifts (\(\gamma\_{001}\)) if asked.

---

### 7. Compare Question 6 to Question 2

**Checklist:**

1. Did **ethnic** coefficients \(\gamma*{010},\gamma*{020},\gamma*{110},\gamma*{120},\gamma*{210},\gamma*{220}\) **change materially** in magnitude or significance once **LOWINC** is in the model?
2. If gaps **shrink** toward zero, frame as **partial confounding** with school poverty: part of the ethnic contrast in Q2 may have reflected **composition** of children across high- vs low-poverty schools.
3. If gaps **stay** similar, ethnic trajectory differences are more **robust** to this school poverty measure.
4. Comment briefly on **variance components**: did school intercept/slope variance (\(\tau\) for \(u\)’s) decline after adding LOWINC, consistent with poverty explaining some **between-school** heterogeneity?

---

## Part B: Revising sector effects (NELS, `nels_hw.mdm`, binary **BAGRAD**)

Outcome **BAGRAD** (1 = earned BA). Student level 1, school level 2; **cross-section** (single time point). **Estimation:** logistic HLM with **EM Laplace**, **1000 max iterations** as assigned.

### 1. Baseline model — sampling model, link, unit-specific estimates

**Sampling model (two-level logistic):**  
Conditional on school random effects, student outcomes are **Bernoulli** with probability \(p\_{ij}\) of graduating college.

**Link:** **logit**: \(\eta*{ij} = \log\big(p*{ij}/(1-p\_{ij})\big)\).

**Level-1 (student \(i\), school \(j\)) — example with random intercept only:**

\[
\eta*{ij} = \beta*{0j} + \beta*1\,\text{FEMALE}*{ij} + \beta*2\,\text{BLACK}*{ij} + \beta*3\,\text{HISPANIC}*{ij} + \beta*4\,\text{ASIAN}*{ij} + \beta*5\,\text{BYSES}*{ij}
\]

\[
\beta*{0j} = \gamma*{00} + u*{0j}, \qquad u*{0j} \sim N(0, \tau\_{00})
\]

**Canvas correction:** There are **three** non-White categories entered as dummies; **White** is **reference** (no **WHITE** dummy, no separate White coefficient row).

**Unit-specific vs population-average:** Your output’s **unit-specific** log-odds/coefficients condition on **estimated** \(u*{0j}\) (school effects); **population-average** estimates marginalize over \(u*{0j}\). For Q1, interpret **unit-specific** \(\gamma\)’s and covariate slopes as in the assignment table.

**Interpretation template:**

- **Intercept (unit-specific):** log-odds of BA for reference profile in a school with \(u\_{0j}=0\).
- **FEMALE:** additive change in log-odds for women vs men, same race/SES within school.
- **BLACK, HISPANIC, ASIAN:** contrasts to **omitted White**, holding gender and BYSES.
- **BYSES:** gradient of log-odds with socioeconomic status.

Paste estimates for **FEMALE, BLACK, HISPANIC, ASIAN, BYSES** and interpret **direction** and **substantive** size (you can note odds = exp(coefficient)).

### 2. Predicted probabilities (unit-specific estimates, other covariates = 0)

Logistic inverse: \(p = \frac{e^\eta}{1+e^\eta}\) with \(\eta = \beta_0 + \beta'\mathbf{x}\).  
Set **FEMALE**, **BLACK**, **HISPANIC**, **ASIAN**, **BYSES** to **0** for each case; use your **\(\hat\beta_0\)** (from unit-specific convention your output uses).

| Person          | Coding                         | Linear predictor \(\eta\)                           | Probability \(p\)               |
| --------------- | ------------------------------ | --------------------------------------------------- | ------------------------------- |
| White male      | Female=0, all race dummies=0   | \(\eta = \hat\beta_0\)                              | \(p = \text{logit}^{-1}(\eta)\) |
| White female    | Female=1, race dummies=0       | \(\eta = \hat\beta*0+\hat\beta*{F}\)                | \(p = …\)                       |
| Hispanic male   | Female=0, Hispanic=1, others=0 | \(\eta = \hat\beta*0+\hat\beta*{H}\)                | \(p = …\)                       |
| Hispanic female | Female=1, Hispanic=1           | \(\eta = \hat\beta*0+\hat\beta*{F}+\hat\beta\_{H}\) | \(p = …\)                       |

**Show the substitution** explicitly with numeric \(\hat\beta\)’s from your run.

### 3. Why the female–probability change differs for Hispanic vs White students

**Short theory:** On the **probability** scale, logistic curves are **non-linear**. A **constant** coefficient on **FEMALE** means an **additive** shift in **log-odds**, which maps to **different** changes in **probability** depending on baseline \(p\). Hispanic and White **profiles** (after setting other variables as in Q2) sit at **different** baseline probabilities, so the **increment in probability** for being female **need not be equal** even though the log-odds increment is the same.

### 4. Catholic sector + controls (**CATHLOC**, **URBAN**, **SCHSIZE**, …) — population-average estimates

**Model (illustrative level-2):**

\[
\beta*{0j} = \gamma*{00} + \gamma*{01}\,\text{CATHLOC}\_j + \gamma*{02}\,\text{URBAN}_j + \gamma_{03}\,\text{SCHSIZE}_j + \cdots + u_{0j}
\]

Enter controls your group chose (assignment lists **URBAN**, **PCTMIN_S**, **SCHSIZE**, **FRELUNCH** as _potential_ controls). **Interpret** **population-average** coefficients for **CATHLOC** and any other **policy-relevant** predictors as required.

**If many coefficients are non-significant:**  
State honestly: after adjusting for **URBAN**, **SCHSIZE**, and **CATHLOC**, evidence for independent effects is **weak** / **null** for some predictors; **CATHLOC** may still retain a clearer pattern—report what **your** output shows. Non-significance can reflect **high collinearity** among school characteristics, **limited power**, or true **small effects**.

### 5. Substantive summary (odds ratio + change in probability for Catholic school)

**Odds ratio:** \(\widehat{OR} = \exp(\hat\gamma\_{\text{CATHLOC}})\) for the Catholic indicator from the **final** model.

**Probability change:** Recompute predicted probabilities for a **clear reference student** (e.g. White male, median or mean SES, chosen values of **URBAN**/**SCHSIZE**) **with CATHLOC = 1 vs 0**, using **population-average** estimates as the hint suggests, and report the **difference in probability**.

**Important:** Explicitly say **for whom** that probability difference is computed (the profile you fixed).

---

## Submission checklist

- [ ] Part A: HLM (or approved) output attached; \(\gamma\) tables filled into Q2, Q6–7.
- [ ] Part A: Trajectory graph for Q3.
- [ ] Part A: Q5 PVIs with numeric bounds from **your** variance components (and **omit** gap PVI if Canvas dropped it).
- [ ] Part B: EM Laplace settings screenshot or statement; Q2 arithmetic shown; Q4–5 use correct **unit-specific** vs **population-average** language.
- [ ] Final merged document reflects **group compilation** order and joint revision.

---

### 给本人与合并文档的说明（中文）

- **White 作参照组**：模型里只放 **Black、Hispanic** 两个虚拟变量即可，**不要**再放 White；所有族裔解释都是相对 White。与 Canvas 上 B1「三个非白人类别」的更正一致。
- **第 5 题**：PDF 原列三项；若老师已划掉「Hispanic–White 的 child-level gap」那一条，按老师版本只写 **White 学生在儿童层、学校层的变异** 两处 PVI 即可；若仍要 gap，对**固定效应**用 \(\gamma \pm 1.96\,SE\) 更合适。
- **合并**：你负责段落可直接与 Amr / Isabella 的 Part B 合并；组员在 sector 模型里加 **CATHLOC、URBAN、SCHSIZE** 后很多系数不显著属常见情况，在 Part B 第 4–5 题里如实写 **p 值/置信区间**，并说明可能共线性或效力不足即可。
- 本文档中凡写「paste」「模板」处，需用你们在 **HLM** 里跑出的 **γ、标准误、tau、图** 替换后才是可交终稿（当前环境未跑 `.sav` 估计）。
