# Garante que a aba de waveform está aberta
view wave

# Limpa as waves atuais
delete wave *

# Entradas
add wave -divider "Entradas"
add wave -radix unsigned /tb_FPU/clk
add wave /tb_FPU/rst
add wave -radix hex /tb_FPU/op_a_in
add wave -radix hex /tb_FPU/op_b_in

# Saídas
add wave -divider "Saídas"
add wave -radix hex /tb_FPU/data_out
add wave -radix binary /tb_FPU/status_out

# (Opcional) Internos
# add wave -divider "Internos"
# add wave -radix unsigned /tb_FPU/uut/expoente_a
# add wave -radix unsigned /tb_FPU/uut/expoente_b

# Ajusta visualização
wave zoom full
