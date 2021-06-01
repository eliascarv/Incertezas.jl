Incertezas
=============
Esse pequeno pacote desenvolvido na Linguagem Julia tem como objetivo criar uma interface para resolução de problemas da disciplina de Metrologia. O mesmo ainda está muito "cru" e pode sofrer grandes mudanças. Quando estiver finalizado ele pode se tornar uma ótima ferramenta de aprendizado para ser utilizado na disciplina de Metrologia.

## Instalação
Entre no modo Pkg no REPL da Linguagem Julia usando o símbolo de fecha colchetes "]". Recomendo que você utilize esse pacote na versão mais recente da Linguagem Julia.
```julia
(@v1.6) pkg> add https://github.com/eliascarv/Incertezas.jl
```

## Requerimentos
- [Linguagem Julia](https://julialang.org/)

## Utilização 
Você pode utilizar o pacote em qualquer ambiente de desenvolvimento que suporte a Linguagem Julia, seja no próprio REPL do Julia, no VS Code com a extensão da Linguagem Julia, no ambiente de notebook [Pluto.jl](https://github.com/fonsp/Pluto.jl), etc.\
Após a instalação do pacote, você pode utilizar os seus tipos e suas funções com a palavra reservada `using` seguida do nome do pacote, no caso `using Incertezas`.
```julia-repl
julia> using Incertezas
```
Agora vamos a um overview das funcionalidades do pacote, iniciaremos pelos tipos.

### Tipos
#### `RM`
O primeiro tipo é o `RM` (Resultado de Medição), esse tipo é a combinação da indicação `I` e da incerteza de medição `U`.\ Para construir um objeto `RM` utilizamos o seguinte método construtor:
```julia
RM(I, U)
```
Resultados de medição tem uma impressão especial, os mesmo são exibidos da seguinte forma: `I ± U`. Por esse motivo também é possível construir um Resultado de Medição como o método construtor especial `±`, no Julia esse símbolo pode ser acessado usando a seguinte sintaxe: `\pm`, após isso clique em `tab` que o símbolo irá aparecer:
```julia
I ± U
```
Como todo objeto na Linguagem Julia, você pode armazenar o seu objeto `RM` em uma variável para operações posteriores:
```julia-repl
julia> a = 2.4 ± 0.5
2.4 ± 0.5
``` 
#### `Medicao`
O objeto `Medicao` extende o objeto `RM` e adicionar um novo fator, os graus de liberdade. Dado que um Resultado de Medição é o resultado da média de várias medições, o grau de liberdade `v` é igual ao número de medições `n` realizadas menos 1, ou seja: `v = n - 1`.\
Para construir um objeto `Medicao` usandos o seguinte método construtor:
```julia 
Medicao(I ± U, v)
```
Exemplo:
```julia-repl
julia> b = Medicao(2.4 ± 0.5, 10)
Medição 
2.4 ± 0.5, v = 10
```
Cabe enfatizar que como a quantidade de medições `n` é um número inteiro, `v` também é. Portanto para esse campo apenas números inteiros são aceitos. Se você passar um número de ponto flutuante (decimal) ele será truncado e apenas a parte inteira do número será usada. Vale salientar também que o campo `v` só aceita número positivos maiores que 0, se um número negativo for passado, uma mensagem de erro será imprimida na tela. Para uma quantidade imensurável de medições, Julia tem a constante especial `Inf`, a mesma também pode ser usada como argumento para o campo `v`. Ex:
```julia-repl
julia> b = Medicao(2.4 ± 0.5, 2.4)
Medição 
2.4 ± 0.5, v = 2

julia> b = Medicao(2.4 ± 0.5, Inf)
Medição 
2.4 ± 0.5, v = Inf
```
### Funções 
#### `student()`
A primeira função que será a função `student`, a mesma retorna o coeficiente de Student para o grau de liberdade `v` que é passado como primeiro argumento, como a distribuição de Student é contínua, v também pode ser um número de ponto flutuante, mesmo assim todas as funções que usam a função `student` truncam o valor passado para `v` ou para `n`, portanto isso não é um problema. O segundo argumento dessa função é a probabilidade do coeficiente de Student, o valor padrão dessa probabilidade é 95,45 %, portanto o mesmo é opcional. Porém caso você queira o coeficiente de Student para uma probabilidade diferente, você pode passar a probabilidade como segundo argumento:
```julia
student(v, prob) 
```
**Argumentos Posicionais**
* `v` - Tipo: `Int`; v ≥ 0; v pode ser `Inf`
* `prob` - Tipo: `Float`; 1 ≥ prob ≥ 0; Valor Padrão: 0.9545`

Exemplo:
```julia-repl
julia> student(4)
2.8693151696963826
```
#### `mens_invar()`
A função `mens_invar` é usada para calcular o resultado de medição de um mensurando invariável. Neste caso duas situações podem ocorrer: `n = 1` e `n > 1`.\
Para `n = 1` a equação para se chegar ao resultado de medição é a seguinte: `RM = I + C ± U`. Vale ressaltar que a incerteza de medição `U` é igual ao produto da incerteza padrão (desvio padrão) `u` multiplicado pelo coeficiente de Student `t`. No caso de apenas uma medição a incerteza de medição deve ser previamente conhecida.\
No segundo caso, o resultado de medição é calculado pela seguida equação: `RM = I̅ + C  ± U/√n`. Em que I̅ é igual a média das medições realizadas.\
Sendo assim, a função `mens_invar` aceita na sua primeira versão, a indicação I (para o primeiro caso) ou a média das medições I̅ (para o segundo caso) como primeiro argumento posicional e a incerteza de medição U como segundo argumento posicional, caso você tenha os valores de u e t e não queira multiplicar os mesmos, uma tupla nomeada na forma: `(u = 4, t = 2.386)`, pode ser passada como argumento posicional no lugar do valor de U
Os argumentos de palavra-chave dessa função são a correção `C`, que tem valor padrão 0 e portanto é opcional, e para o segundo caso o número de medições realizadas `n`. No primeiro caso a função retorna um objeto `RM`, no segundo retorna um objeto `Medicao`.

Primeiro caso:
```julia
mens_invar(I, U; C)
```
**Argumentos Posicionais**
* `I` - Tipo: `Real`
* `U` - Tipo: `Real` ou `NamedTuple`

**Argumentos de Palavra-chave**
* `C` - Tipo: `Real`; Valor Padrão: 0

Exemplos:
```julia-repl
julia> mens_invar(4.5, 2.2, C = -0.3)
4.2 ± 2.2

julia> mens_invar(4.5, (u = 1.1, t = 2), C = -0.3)
4.2 ± 2.2
```
\
Segundo caso:
```julia
mens_invar(I̅, U; C, n)
```
**Argumentos Posicionais**
* `I̅` - Tipo: `Real`
* `U` - Tipo: `Real` ou NamedTuple

**Argumentos de Palavra-chave**
* `C` - Tipo: `Real`; Valor Padrão: 0
* `n` - Tipo: `Int`, se for pssado um Float ele será truncado; Aceita `Inf`

Exemplos:
```julia-repl
julia> mens_invar(4.5, 2.2, C = -0.3, n = 4)
Medição
4.2 ± 1.1, v = 3

julia> mens_invar(4.5, (u = 1.1, t = 2), C = -0.3, n = 4)
Medição
4.2 ± 1.1, v = 3
```
\
A segunda versão da função `mens_invar` é aplicada apenas para o segundo caso. Nessa versão o único argumento posicional é um vetor contendo todas as medições realizadas. Os argumentos de palavras-chave são a correção `C` que tem vaor padrão 0 e a probabilidade `prob` que tem valor padrão 0.9545, portanto ambos são opcionais:
```julia
mens_invar(I; C, prob)
```
**Argumentos Posicionais**
* `I` - Tipo: `Vector`

**Argumentos de Palavra-chave**
* `C` - Tipo: `Real`; Valor Padrão: 0
* `prob` - Tipo: `Float`; Valor Padrão: 0.9545

Exemplos:
```julia-repl
julia> I = [4.4, 4.3, 4.7, 4.1, 4.6]
5-element Vector{Float64}:
 4.4
 4.3
 4.7
 4.1
 4.6

julia> mens_invar(I)
Medição
4.42 ± 0.30636, v = 4

julia> mens_invar(I, C = -0.3)
Medição
4.12 ± 0.30636, v = 4

julia> mens_invar(I, C = -0.3, prob = 0.9)
Medição
4.12 ± 0.22762, v = 4
```
#### `mens_invar_emax()`
Para o terceiro caso temos um mensurado invariável e o erro máximo do sistema de medição medição. Nesse caso a equação para uma medição é: `RM = I ± Emax` e para mais de uma medição é : `RM = I̅ ± Emax`.\
A primeira versão dessa função é muito simples, e simplesmente aceita o valor da única indicação ou da média das indicações como primeiro argumento posicional e o errmo máximo como segundo argumento posicional.
```julia
mens_invar_emax(I, Emax)
```
**Argumentos Posicionais**
* `I` - Tipo: `Real`
*  `Emax` - Tipo: `Real`

Exemplo:
```julia-repl
julia> mens_invar_emax(4.7, 0.6)
4.7 ± 0.6
```
\
Já a segunda versão da função `mens_invar_emax` aceita como primeiro argumento posicional um vetor com as medições realizadas e um segundo argumento posicional com o erro máximo.
```julia
mens_invar_emax(I, Emax)
```
**Argumentos Posicionais**
* `I` - Tipo: `Vector`
* `Emax` - Tipo: `Real`

Exemplo:
```julia-repl
julia> I = [4.4, 4.3, 4.7, 4.1, 4.6]
5-element Vector{Float64}:
 4.4
 4.3
 4.7
 4.1
 4.6

julia> mens_invar_emax(I, 0.6)
Medição
4.42 ± 0.6, v = 4
```
#### `mens_var()`
O quarto caso refere-se a um mensurando variável em que foram realizadas mais de uma medição. A equação para encontrar o resultado de medição nesse caso é: `RM = I̅ + C ± U`.\
Na primeira versão da função `mens_var` temos a média das indicações como primeiro argumento posicional e a incerteza de medição como segundo argumento posicional, para os argumentos de palavra-chave temos 
Na primeira versão da função `mens_var` temos a média das indicações como primeiro argumento posicional e a incerteza de medição como segundo argumento posicional, para os argumentos de palavra-chave temos 
a correção `C` que tem valor padrão 0, o número de medições realizadas `n` que tem valor padrão `Inf`.
```julia
mens_var(I̅, U; C, n)
```
**Argumentos Posicionais**
* `I̅` - Tipo: `Real`
* `U` - Tipo: `Real` ou `NamedTuple`

**Argumentos de Palavra-chave**
* `C` - Tipo `Real`; Valor Padrão: 0
* `n` - Tipo `Int`; Valor Padrão: `Inf`

Exemplo:
```julia-repl
julia> mens_var(4.3, 2.2, C = -0.5, n = 14)
Medição
3.8 ± 2.2, v = 13

julia> mens_var(4.3, (u = 1.1, t = 2), C = -0.5, n = 14)
Medição
3.8 ± 2.2, v = 13

julia> mens_var(4.3, (u = 1.1, t = 2), C = -0.5)
Medição
3.8 ± 2.2, v = Inf
```
 A segunda versão da função `mens_var` aceita como único argumento posicional um vetor com as medições realizadas, os argumentos de palavra-chave são: a correção `C` que tem valor padrão 0 e a probabilidade `prob` que tem valor padrão de 0.9545.
 ```julia
 mens_var(I; C, prob)
 ```
 **Argumentos Posicionais**
 * `I` - Tipo: `Vector`
 
**Argumentos de Palavra-chave**
* `C` - Tipo: `Real`; Valor Padrão 0
* `prob` - Tipo: `Float`; Valor Padrão 0.9545

Exemplo:
```julia-repl
julia> I = [4.4, 4.3, 4.7, 4.1, 4.6]
5-element Vector{Float64}:
 4.4
 4.3
 4.7
 4.1
 4.6

julia> mens_var(I)
Medição
4.42 ± 0.68504, v = 4

julia> mens_var(I, C = -0.2)
Medição
4.22 ± 0.68504, v = 4

julia> mens_var(I, C = -0.2, prob = 0.9)
Medição
4.22 ± 0.50897, v = 4
```
 #### `mens_var_emax()`
 Para o quinto caso temos um mensurando variável que foi medido mais de uma vez e o erro máximo do sistema de medição. A equação para encontrar o resultado de medição nesse caso é: `RM = I̅ ± U + Emax`.\
 Na primeira versão da função `mens_var_emax`, temos como argumentos posicionais a indicação média, a incerteza da medição e o erro máximo, o único argumento de palavra-chave é o número de medições `n` que tem valor padrão `Inf`.
 ```julia
 mens_var_emax(I̅, U, Emax; n)
 ```
 **Argumentos Posicionais**
 * `I̅` - Tipo: `Real`
 * `U` - Tipo: `Real` ou `NamedTuple`
 * `Emax` - Tipo: `Real`
 
**Argumentos de Palavra-chave**
* `n` - Tipo: `Int`; Valor Padrão `Inf`

Exemplo:
```julia-repl
julia>  mens_var_emax(4.42, 0.67, 1.4, n = 40)
Medição
4.42 ± 2.07, v = 39

julia>  mens_var_emax(4.42, (u = 0.2, t = 2), 1.4, n = 40)
Medição
4.42 ± 1.8, v = 39

julia>  mens_var_emax(4.42, (u = 0.2, t = 2), 1.4)
Medição
4.42 ± 1.8, v = Inf
```
\
A segunda versão da função `mens_var_emax` é um pouco mais prática e aceita como primeiro argumento posicional um vetor contendo todas as medições realizadas e como segundo argumento posicional o erro máximo, o único argumento de palavra-chave é a probabilidade `prob` que tem valor padrão de 0.9545.
```julia
mens_var_emax(I, Emax; prob)
```
**Argumentos Posicionais**
* `I` - Tipo: `Vector`
* `Emxa` - Tipo: `Real`

**Argumentos de Palavra-chave**
* `prob` - Tipo: `Float`; Valor Padrão 0.9545

Exemplo:
```julia-repl
julia> I = [4.4, 4.3, 4.7, 4.1, 4.6]
5-element Vector{Float64}:
 4.4
 4.3
 4.7
 4.1
 4.6

julia> mens_var_emax(I, 1.6)
Medição
4.42 ± 2.28504, v = 4

julia> mens_var_emax(I, 1.6, prob = 0.92)
Medição
4.42 ± 2.15697, v = 4
```
## Operações com Medições não Correlacionadas 
Considerando que as medições realizadas são estatisticamente independentes (não correlacionadas) podemos definir operações matemáticas entre as medições para encontrar o resultado de medição de um mensurado que tenha as mesmas como suas componentes. Por exemplo a área de uma chapa de metal, sabendo que o mesmo tem as seguintes dimensões: (0.3 ± 0.01) m de comprimento e (0.5 ± 0.02) m de largura, e sabendo que ambas as dimensões foram medidas incontáveis vezes, qual será o resultado de medição da área?\
Para resolver esses problemas as 4 operações fundamentais da matemáticas e a exponenciação por números inteiros (mais operações serão adicionadas no futuro) foram definidas para operar com objetos `Medicao` e retornar o resultado de medição.\
O cálculo realizado por essas operações é muito complexo e a explicação dos mesmos não será aprofundada.\
Agora vamos a alguns exemplos:
```julia-repl
julia> a = Medicao(2.3 ± 0.6, 5)
Medição
2.3 ± 0.6, v = 5

julia> a + a
Medição
4.6 ± 0.7316, v = 10

julia> a - a
Medição
0.0 ± 0.7316, v = 10

julia> a * a
Medição
5.29 ± 1.68269, v = 10

julia> a / a
Medição
1.0 ± 0.31809, v = 10

julia> a^2
Medição
5.29 ± 2.76, v = 5

julia> 2 * a
Medição
4.6 ± 1.2, v = 5

julia> a * 2
Medição
4.6 ± 1.2, v = 5

julia> a / 2
Medição
1.15 ± 0.3, v = 5
```
\
Exemplo da chapa de metal:
```julia-repl
julia> c = Medicao(0.3 ± 0.01, Inf)
Medição
0.3 ± 0.01, v = Inf

julia> l = Medicao(0.5 ± 0.02, Inf)
Medição
0.5 ± 0.02, v = Inf

julia> area = c * l
Medição
0.15 ± 0.00781, v = Inf
```
\
Cálculo da massa específica de um Cilindro:
```julia-repl
julia> m = Medicao(1580 ± 22, 14)
Medição
1580.0 ± 22.0, v = 14

julia> D = Medicao(25.423 ± 0.006, Inf)
Medição
25.423 ± 0.006, v = Inf

julia> h = Medicao(77.35 ± 0.11, 14)
Medição
77.35 ± 0.11, v = 14

julia> y = (4/π) * m/(D^2 * h)
Medição
0.04024 ± 0.00056, v = 14
```
