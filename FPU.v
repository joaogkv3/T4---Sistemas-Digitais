module FPU (
    input wire clk,
    input wire rst,
    input wire [31:0] op_a_in,
    input wire [31:0] op_b_in,
    output reg [31:0] data_out,
    output reg [3:0] status_out  // [EXACT, OVERFLOW, UNDERFLOW, INEXACT]
);

    // Parâmetros de formato
    parameter EXP_WIDTH      = 11;
    parameter MANTISSA_WIDTH = 20;
    parameter EXP_MAX        = (1 << EXP_WIDTH) - 1;

    // Campos
    reg sinal_a, sinal_b, sinal_res;
    reg [EXP_WIDTH-1:0] expoente_a, expoente_b, expoente_res, expoente_norm;
    reg [MANTISSA_WIDTH:0] mantissa_a, mantissa_b; // com hidden bit

    // Operações intermediárias
    reg [MANTISSA_WIDTH+4:0] mantissa_a_shifted, mantissa_b_shifted;
    reg [MANTISSA_WIDTH+5:0] mantissa_res;
    reg [MANTISSA_WIDTH+5:0] mantissa_norm;

    // Status flags
    reg overflow_flag, underflow_flag, inexact_flag, exact_flag;

    integer diff_exp, shift_count;

    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            data_out    <= 32'b0;
            status_out  <= 4'b0000;
        end else begin

            //------------------------------------------
            // EXTRAÇÃO DOS CAMPOS
            //------------------------------------------
            sinal_a    <= op_a_in[31];
            sinal_b    <= op_b_in[31];

            expoente_a <= op_a_in[30:20];
            expoente_b <= op_b_in[30:20];

            mantissa_a <= {1'b1, op_a_in[19:0]};
            mantissa_b <= {1'b1, op_b_in[19:0]};

            //------------------------------------------
            // ALINHAMENTO DOS EXPOENTES
            //------------------------------------------
            if (expoente_a > expoente_b) begin
                diff_exp = expoente_a - expoente_b;
                expoente_res = expoente_a;
                mantissa_a_shifted = {mantissa_a, 4'b0000}; // padding para deslocamento seguro
                mantissa_b_shifted = ({mantissa_b, 4'b0000} >> diff_exp);
            end else if (expoente_b > expoente_a) begin
                diff_exp = expoente_b - expoente_a;
                expoente_res = expoente_b;
                mantissa_a_shifted = ({mantissa_a, 4'b0000} >> diff_exp);
                mantissa_b_shifted = {mantissa_b, 4'b0000};
            end else begin
                diff_exp = 0;
                expoente_res = expoente_a;
                mantissa_a_shifted = {mantissa_a, 4'b0000};
                mantissa_b_shifted = {mantissa_b, 4'b0000};
            end

            //------------------------------------------
            // SOMA OU SUBTRAÇÃO
            //------------------------------------------
            if (sinal_a == sinal_b) begin
                mantissa_res = mantissa_a_shifted + mantissa_b_shifted;
                sinal_res = sinal_a;
            end else begin
                if (mantissa_a_shifted >= mantissa_b_shifted) begin
                    mantissa_res = mantissa_a_shifted - mantissa_b_shifted;
                    sinal_res = sinal_a;
                end else begin
                    mantissa_res = mantissa_b_shifted - mantissa_a_shifted;
                    sinal_res = sinal_b;
                end
            end

            //------------------------------------------
            // NORMALIZAÇÃO
            //------------------------------------------
            mantissa_norm = mantissa_res;
            expoente_norm = expoente_res;
            shift_count = 0;

            if (mantissa_res[MANTISSA_WIDTH+5]) begin
                // Overflow na soma — shift right
                mantissa_norm = mantissa_res >> 1;
                expoente_norm = expoente_res + 1;
                shift_count = 0;
            end else begin
                // Normalização para a esquerda
                while (mantissa_norm[MANTISSA_WIDTH+4] == 0 && mantissa_norm != 0) begin
                    mantissa_norm = mantissa_norm << 1;
                    shift_count = shift_count + 1;
                end

                if (shift_count > expoente_res) begin
                    expoente_norm = 0;
                    underflow_flag = 1;
                end else begin
                    expoente_norm = expoente_res - shift_count;
                    underflow_flag = 0;
                end
            end

            //------------------------------------------
            // OVERFLOW CHECK
            //------------------------------------------
            if (expoente_norm >= EXP_MAX) begin
                overflow_flag = 1;
            end else begin
                overflow_flag = 0;
            end

            //------------------------------------------
            // EXACT / INEXACT
            //------------------------------------------
            if (overflow_flag || underflow_flag || shift_count != 0) begin
                inexact_flag = 1;
                exact_flag = 0;
            end else begin
                inexact_flag = 0;
                exact_flag = 1;
            end

            //------------------------------------------
            // MONTAGEM DO RESULTADO
            //------------------------------------------
            if (mantissa_res == 0) begin
                data_out = 32'b0;
            end else begin
                data_out = {sinal_res, expoente_norm, mantissa_norm[MANTISSA_WIDTH+3:MANTISSA_WIDTH-16]};
            end

            //------------------------------------------
            // STATUS OUT — [EXACT, OVERFLOW, UNDERFLOW, INEXACT]
            //------------------------------------------
            status_out = {exact_flag, overflow_flag, underflow_flag, inexact_flag};

        end
    end

endmodule
