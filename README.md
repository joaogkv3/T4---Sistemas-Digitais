Relatório - Trabalho T4 - FPU de Ponto Flutuante
Disciplina: Sistemas Digitais
Aluno: João Gabriel Kunz Viana
Matrícula: 23103883-7
1. Cálculo dos parâmetros X e Y (Baseados na matrícula)
Matrícula: 23103883-7

Para o Expoente (X):
(83 MOD 5) + 5 = (3) + 5 = 8 bits
Resultado: Expoente com 8 bits

Para a Mantissa (Y):
(83 MOD 11) + 10 = (6) + 10 = 16 bits
Resultado: Mantissa com 16 bits
2. Definição da Interface da FPU
Sinal	Direção	Largura	Descrição
clk	IN	1 bit	Clock
rst	IN	1 bit	Reset síncrono (ativo em nível alto)
op_a_in	IN	32 bits	Operando A (formato de ponto flutuante)
op_b_in	IN	32 bits	Operando B (formato de ponto flutuante)
data_out	OUT	32 bits	Resultado da operação
status_out	OUT	4 bits	Flags de status: [EXACT, OVERFLOW, UNDERFLOW, INEXACT]

Formato dos operandos e saída (op_a_in, op_b_in, data_out):
| Sinal (1 bit) | Expoente (8 bits) | Mantissa (16 bits) |

3. Funcionamento Interno da FPU
   
1. Extração dos campos:
O operando de 32 bits é decomposto em sinal, expoente e mantissa, com hidden bit implícito.

2. Alinhamento:
O operando com expoente menor tem sua mantissa deslocada à direita até igualar o expoente maior.

3. Operação:
Se sinais iguais, soma as mantissas. Se diferentes, subtrai a menor da maior.

4. Normalização:
Se soma gera overflow, desloca à direita e incrementa o expoente.
Se subtração gera número menor, desloca à esquerda e decrementa o expoente.

5. Status gerados:
EXACT, OVERFLOW, UNDERFLOW e INEXACT.
4. Espectro Numérico Representável
Expoente: 8 bits, valores de 0 a 255.
Mantissa: 16 bits, precisão de 1 + 16 bits.

Maior número positivo:
(2^(255 - bias)) × (1 + mantissa máxima), onde o bias geralmente é 127.

Menor número positivo normalizado:
(2^(1 - bias)) × (1.0), muito próximo de zero.

Menor número negativo e maior número negativo são iguais em módulo, com sinal invertido.

Baseado na representação semelhante à figura 2-5 do padrão IEEE754.
5. Testbench – Casos de Teste
Teste	Operação	Entrada A (hex)	Entrada B (hex)	Saída Esperada	Descrição
1	2 + 3	00500000	00600000	00700000	Soma simples
2	5 - 2	00700000	00500000	00600000	Subtração
3	3 + 0	00600000	00000000	00600000	Elemento neutro
4	4 - 4	00600000	00600000	00000000	Resultado zero
5	Small + Small	00100000	00100000	00000000	Underflow
6	Big + Small	7FE00000	00100000	7FF00000	Overflow
7	Small + Small (round)	00800001	00800001	xxxx	Arredondamento
8	5 + (-8)	00700000	80500000	80600000	Subtração com sinais opostos
9	(-2) + (-3)	80500000	80600000	80700000	Soma de negativos
10	(-7) + 4	80900000	00600000	80600000	Subtração cruzada

7. Instruções de Simulação
   
1. Abra o ModelSim.
2. Mude o diretório para a pasta do projeto.
3. Execute:
do sim.do

O script irá:
- Criar a biblioteca work.
- Compilar FPU.v e tb_FPU.v.
- Abrir a simulação tb_FPU.
- Carregar automaticamente a visualização das ondas (wave.do).
  
8. Arquivos no Projeto
   
/Projeto_T4/
├── FPU.v
├── tb_FPU.v
├── sim.do
├── wave.do
├── README.docx

10. Conclusão
    
O projeto implementa uma Unidade de Ponto Flutuante (FPU) capaz de realizar soma e subtração com suporte  a normalização, alinhamento de expoentes e geração de status (EXACT, OVERFLOW, UNDERFLOW, INEXACT). Todo o desenvolvimento foi validado através de 10 casos de teste, cobrindo operações normais, casos de borda e situações de overflow/underflow.
