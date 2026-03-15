# Roman Numerals Converter Transducer

## 1. Formal Definition / Definição Formal
 
### English
 
A **Transducer** is a finite automaton extended with an output function. The implementation in this code is formally defined as a **6-tuple**:
 
$$\mathcal{T} = (Q,\ \Sigma,\ \Delta,\ \delta,\ \lambda,\ q_0)$$
 
| Component | Symbol | Value in this implementation |
|---|---|---|
| Finite set of states | Q | `{q0, qM, qMM, qMMM, qC, qCC, qCCC, qD, q_sub_h, qX, qXX, qXXX, qL, q_sub_t, qI, qII, qIII, qV, q_final}` |
| Input alphabet | Σ | `{I, V, X, L, C, D, M, ε}` |
| Output alphabet | Δ | `ℤ≥0` (non-negative integers, accumulated in `@result`) |
| Transition function | δ: Q × Σ → Q | The `case [symbol, state]` block |
| Output function | λ: Q × Σ → Δ | The `@result += N` side-effect on each transition |
| Initial state | q₀ | `"q0"` |
 
Every state in `Q` is also an **accepting state** — the machine accepts on the empty symbol `ε` regardless of which state it is currently in. This means any well-formed Roman numeral prefix is accepted, and the final value of `@result` is the transduced output.
 
---
 
### Português
 
Um **Transdutor** é um autômato finito estendido com uma função de saída. A implementação neste código é formalmente definida como uma **6-tupla**:
 
$$\mathcal{T} = (Q,\ \Sigma,\ \Delta,\ \delta,\ \lambda,\ q_0)$$
 
| Componente | Símbolo | Valor nesta implementação |
|---|---|---|
| Conjunto finito de estados | Q | `{q0, qM, qMM, qMMM, qC, qCC, qCCC, qD, q_sub_h, qX, qXX, qXXX, qL, q_sub_t, qI, qII, qIII, qV, q_final}` |
| Alfabeto de entrada | Σ | `{I, V, X, L, C, D, M, ε}` |
| Alfabeto de saída | Δ | `ℤ≥0` (inteiros não-negativos, acumulados em `@result`) |
| Função de transição | δ: Q × Σ → Q | O bloco `case [symbol, state]` |
| Função de saída | λ: Q × Σ → Δ | O efeito colateral `@result += N` em cada transição |
| Estado inicial | q₀ | `"q0"` |
 
Todo estado em `Q` é também um **estado aceitador** — a máquina aceita ao encontrar o símbolo vazio `ε` independentemente do estado atual. Qualquer prefixo romano bem-formado é aceito, e o valor final de `@result` é a saída transduzida.
 
---
 
## 2. Mealy or Moore? / Mealy ou Moore?
 
### English
 
This implementation is a **Mealy Machine**.
 
The defining difference between the two models is *where* the output is attached:
 
| Property | Moore Machine | Mealy Machine |
|---|---|---|
| Output associated with | **States** | **Transitions** |
| Output function signature | λ: Q → Δ | λ: Q × Σ → Δ |
| Output produced | Upon entering a state | Upon consuming a symbol |
| Output depends on | Current state only | Current state **and** current input |
 
In this code, every `@result += N` is written **inside** a `case [symbol, state]` branch — meaning the output is produced by the pair *(current state, current input symbol)*, not by the state alone. This is the exact definition of a Mealy machine.
 
**Why not Moore?** A Moore machine would require associating a fixed numeric increment with each state, regardless of which symbol triggered the transition into it. That is impossible here: for example, state `q_sub_h` can be reached via `qC + D` (producing +300) or `qC + M` (producing +800). The output depends on the input symbol, not on the destination state.
 
**Input alphabet Σ:**
 
```
Σ = { :I, :V, :X, :L, :C, :D, :M, :"" }
```
 
The symbol `:"" ` (empty symbol / ε) is the end-of-tape marker that triggers acceptance. It is a member of Σ handled by the pattern `[:"", _]`.
 
**Output alphabet Δ:**
 
```
Δ ⊆ ℤ≥0
```
 
The output is not a discrete symbol emitted per transition, but a **numeric increment** accumulated in `@result`. Each non-accepting transition emits a positive integer delta. The complete output word is the final accumulated value — a single integer representing the Arabic numeral equivalent.
 
---
 
### Português
 
Esta implementação é uma **Máquina de Mealy**.
 
A diferença fundamental entre os dois modelos é *onde* a saída está associada:
 
| Propriedade | Máquina de Moore | Máquina de Mealy |
|---|---|---|
| Saída associada a | **Estados** | **Transições** |
| Assinatura da função de saída | λ: Q → Δ | λ: Q × Σ → Δ |
| Saída produzida | Ao entrar num estado | Ao consumir um símbolo |
| Saída depende de | Estado atual apenas | Estado atual **e** símbolo de entrada |
 
Neste código, todo `@result += N` é escrito **dentro** de um ramo `case [symbol, state]` — ou seja, a saída é produzida pelo par *(estado atual, símbolo de entrada atual)*, não pelo estado isoladamente. Esta é a definição exata de uma máquina de Mealy.
 
**Por que não Moore?** Uma máquina de Moore exigiria associar um incremento numérico fixo a cada estado, independentemente de qual símbolo disparou a transição. Isso é impossível aqui: por exemplo, o estado `q_sub_h` pode ser alcançado via `qC + D` (produzindo +300) ou `qC + M` (produzindo +800). A saída depende do símbolo de entrada, não do estado de destino.
 
**Alfabeto de entrada Σ:**
 
```
Σ = { :I, :V, :X, :L, :C, :D, :M, :"" }
```
 
O símbolo `:"" ` (símbolo vazio / ε) é o marcador de fim de fita que dispara a aceitação. É um membro de Σ tratado pelo padrão `[:"", _]`.
 
**Alfabeto de saída Δ:**
 
```
Δ ⊆ ℤ≥0
```
 
A saída não é um símbolo discreto emitido por transição, mas um **incremento numérico** acumulado em `@result`. Cada transição não-aceitadora emite um delta inteiro positivo. A palavra de saída completa é o valor acumulado final — um único inteiro que representa o numeral arábico equivalente.
 
---
 
## 3. Transitions With and Without Output / Transições Com e Sem Saída
 
### English
 
#### Transitions that emit output — λ(q, σ) ∈ Δ
 
These are the core Mealy transitions. Each produces a numeric increment as a side-effect.
 
| Current State | Input Symbol | Next State | Output (Δ) | Numeral Context |
|---|---|---|---|---|
| `q0` | `M` | `qM` | **+1000** | M = 1000 |
| `qM` | `M` | `qMM` | **+1000** | MM = 2000 |
| `qMM` | `M` | `qMMM` | **+1000** | MMM = 3000 |
| `q0` | `C` | `qC` | **+100** | C = 100 |
| `qC` | `C` | `qCC` | **+100** | CC = 200 |
| `qD` | *(any tens)* | `qX/qL` | **+10 / +50** | DX = 510 |
| `qX` | `X` | `qXX` | **+10** | XX = 20 |
| `qI` | `I` | `qII` | **+1** | II = 2 |
| `qII` | `I` | `qIII` | **+1** | III = 3 |
| `q0` | `V` | `qV` | **+5** | V = 5 |
 
**Subtractive transitions** (the most distinctive Mealy behaviour):
 
| Current State | Input Symbol | Next State | Output (Δ) | Explanation |
|---|---|---|---|---|
| `qC` | `D` | `q_sub_h` | **+300** | CD = 400; already emitted +100 for C, now +300 = 400 total |
| `qC` | `M` | `q_sub_h` | **+800** | CM = 900; already emitted +100 for C, now +800 = 900 total |
| `qX` | `L` | `q_sub_t` | **+30** | XL = 40; already emitted +10 for X, now +30 = 40 total |
| `qX` | `C` | `q_sub_t` | **+80** | XC = 90; already emitted +10 for X, now +80 = 90 total |
| `qI` | `V` | `q_final` | **+3** | IV = 4; already emitted +1 for I, now +3 = 4 total |
| `qI` | `X` | `q_final` | **+8** | IX = 9; already emitted +1 for I, now +8 = 9 total |
 
#### Transitions without output — λ(q, σ) = ∅
 
These transitions change state but produce **no increment** to `@result`. The output alphabet is silent.
 
| Current State | Input Symbol | Next State | Output | Reason |
|---|---|---|---|---|
| *(any)* | `ε` | *(accept)* | **none** | End-of-tape: triggers `break`, no `@result +=` is executed |
| *(invalid pair)* | *(any)* | *(reject)* | **none** | Falls into the `else` branch; returns `nil`, no output produced |
 
The acceptance transition `[:"", _]` is the clearest example of an **output-free transition**: it changes the machine's status (from running to accepted) but emits nothing into Δ. The value of `@result` at that moment is the complete transduced output, produced entirely by previous transitions.
 
---
 
### Português
 
#### Transições que emitem saída — λ(q, σ) ∈ Δ
 
São as transições centrais da Máquina de Mealy. Cada uma produz um incremento numérico como efeito colateral.
 
| Estado Atual | Símbolo de Entrada | Próximo Estado | Saída (Δ) | Contexto do Numeral |
|---|---|---|---|---|
| `q0` | `M` | `qM` | **+1000** | M = 1000 |
| `qM` | `M` | `qMM` | **+1000** | MM = 2000 |
| `qMM` | `M` | `qMMM` | **+1000** | MMM = 3000 |
| `q0` | `C` | `qC` | **+100** | C = 100 |
| `qC` | `C` | `qCC` | **+100** | CC = 200 |
| `qD` | *(qualquer dezena)* | `qX/qL` | **+10 / +50** | DX = 510 |
| `qX` | `X` | `qXX` | **+10** | XX = 20 |
| `qI` | `I` | `qII` | **+1** | II = 2 |
| `qII` | `I` | `qIII` | **+1** | III = 3 |
| `q0` | `V` | `qV` | **+5** | V = 5 |
 
**Transições subtrativas** (o comportamento Mealy mais distintivo):
 
| Estado Atual | Símbolo de Entrada | Próximo Estado | Saída (Δ) | Explicação |
|---|---|---|---|---|
| `qC` | `D` | `q_sub_h` | **+300** | CD = 400; já emitiu +100 para C, agora +300 = total 400 |
| `qC` | `M` | `q_sub_h` | **+800** | CM = 900; já emitiu +100 para C, agora +800 = total 900 |
| `qX` | `L` | `q_sub_t` | **+30** | XL = 40; já emitiu +10 para X, agora +30 = total 40 |
| `qX` | `C` | `q_sub_t` | **+80** | XC = 90; já emitiu +10 para X, agora +80 = total 90 |
| `qI` | `V` | `q_final` | **+3** | IV = 4; já emitiu +1 para I, agora +3 = total 4 |
| `qI` | `X` | `q_final` | **+8** | IX = 9; já emitiu +1 para I, agora +8 = total 9 |
 
#### Transições sem saída — λ(q, σ) = ∅
 
Essas transições mudam de estado mas **não produzem incremento** em `@result`. O alfabeto de saída fica silencioso.
 
| Estado Atual | Símbolo de Entrada | Próximo Estado | Saída | Motivo |
|---|---|---|---|---|
| *(qualquer)* | `ε` | *(aceitar)* | **nenhuma** | Fim de fita: dispara `break`, nenhum `@result +=` é executado |
| *(par inválido)* | *(qualquer)* | *(rejeitar)* | **nenhuma** | Cai no ramo `else`; retorna `nil`, nenhuma saída produzida |
 
A transição de aceitação `[:"", _]` é o exemplo mais claro de uma **transição sem saída**: ela muda o status da máquina (de em execução para aceito) mas não emite nada em Δ. O valor de `@result` naquele momento é a saída transduzida completa, produzida inteiramente pelas transições anteriores.
 
---
 
## Summary / Resumo
 
| | English | Português |
|---|---|---|
| **Model** | Mealy Machine | Máquina de Mealy |
| **Output trigger** | Transition (state + symbol) | Transição (estado + símbolo) |
| **Input alphabet** | `{I, V, X, L, C, D, M, ε}` | `{I, V, X, L, C, D, M, ε}` |
| **Output alphabet** | Non-negative integers (ℤ≥0) | Inteiros não-negativos (ℤ≥0) |
| **Accepting states** | All states (on ε) | Todos os estados (em ε) |
| **Silent transitions** | ε (accept) and reject (else) | ε (aceitar) e rejeição (else) |
| **Key insight** | Subtractive pairs use retroactive compensation | Pares subtrativos usam compensação retroativa |


## Usage

```
ruby main.rb
```

## Contributing

Bug reports and pull requests are welcome on GitHub. This project is intended to be a safe, welcoming space for collaboration.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
