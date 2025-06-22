`timescale 1ns/1ps

module tb_FPU;

    // Entradas
    reg clk;
    reg rst;
    reg [31:0] op_a_in;
    reg [31:0] op_b_in;

    // Saídas
    wire [31:0] data_out;
    wire [3:0] status_out;

    // Instância da FPU
    FPU uut (
        .clk(clk),
        .rst(rst),
        .op_a_in(op_a_in),
        .op_b_in(op_b_in),
        .data_out(data_out),
        .status_out(status_out)
    );

    // Clock 10ns
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

   // Estímulos
    initial begin
        // Inicializa
        rst = 0;
        op_a_in = 32'b0;
        op_b_in = 32'b0;

        // Reset
        #20 rst = 1;

        // ==========================
        // Teste 1: 2 + 3
        // ==========================
        #20;
        op_a_in = 32'h00500000; // 2
        op_b_in = 32'h00600000; // 3

        // ==========================
        // Teste 2: 5 - 2
        // ==========================
        #40;
        op_a_in = 32'h00700000; // 5
        op_b_in = 32'h00500000; // 2

        // ==========================
        // Teste 3: 3 + 0
        // ==========================
        #40;
        op_a_in = 32'h00600000; // 3
        op_b_in = 32'h00000000; // 0

        // ==========================
        // Teste 4: 4 - 4
        // ==========================
        #40;
        op_a_in = 32'h00600000; // 4
        op_b_in = 32'h00600000; // 4

        // ==========================
        // Teste 5: very small + very small (underflow)
        // ==========================
        #40;
        op_a_in = 32'h00100000; // very small
        op_b_in = 32'h00100000; // very small

        // ==========================
        // Teste 6: big + small (overflow)
        // ==========================
        #40;
        op_a_in = 32'h7FE00000; // very big
        op_b_in = 32'h00100000; // small

        // ==========================
        // Teste 7: soma pequena (testa arredondamento)
        // ==========================
        #40;
        op_a_in = 32'h00800001; // pequeno + bit na mantissa
        op_b_in = 32'h00800001; //

        // ==========================
        // Teste 8: 5 + (-8)
        // ==========================
        #40;
        op_a_in = 32'h00700000; // 5
        op_b_in = 32'h80500000; // -8

        // ==========================
        // Teste 9: (-2) + (-3)
        // ==========================
        #40;
        op_a_in = 32'h80500000; // -2
        op_b_in = 32'h80600000; // -3

        // ==========================
        // Teste 10: (-7) + 4
        // ==========================
        #40;
        op_a_in = 32'h80900000; // -7
        op_b_in = 32'h00600000; // 4

        // Fim dos testes
        #100;
        $stop;
    end

endmodule
