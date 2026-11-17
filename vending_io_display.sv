module vending_io_display (
    input  logic clk,
    input  logic reset_n,          // KEY3 (active low reset)
    input  logic [9:0]   switches,         // Used for row/column index selection
    input  logic [2:0]   keys,             // KEY0, KEY1, KEY2 for functions
    
    // Interface signals from FSM and Payment/Inventory logic
    input  logic [3:0]   current_state,    // FSM state or operation mode
    input  logic [7:0]   item_price,       // Price of selected item or stock count
    input  logic [7:0]   total_balance,    // Total inserted balance due
    input  logic [7:0]   change_due,       // Change returned after purchase
    output logic [3:0]   selected_row,     // Decoded row index from switches
    output logic [3:0]   selected_col,     // Decoded column index from switches
    
    output logic [6:0]   hex0,             // 7-segment display 0 (Units / Lower digit)
    output logic [6:0]   hex1,             // 7-segment display 1 (Tens / Upper digit)
    output logic [6:0]   hex2,             // 7-segment display 2 (Row/Col or status)
    output logic [6:0]   hex3,             // 7-segment display 3 (Mode/Status)
    output logic         key_press_pulse   // Debounced/synchronized pulse for FSM
);

    // Switch Decoding for 2-D Array Row and Column
    always_comb begin
        selected_row = switches[3:0];
        selected_col = switches[7:4];
    end

    // Button Synchronization and Edge Detection (Active-Low Keys)
    logic [2:0] key_sync_0, key_sync_1;
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            key_sync_0 <= 3'b111;
            key_sync_1 <= 3'b111;
        end else begin
            key_sync_0 <= keys;
            key_sync_1 <= key_sync_0;
        end
    end

    // Detect falling edge (button press since keys are active low)
    logic [2:0] key_pressed;
    assign key_pressed = ~key_sync_0 & key_sync_1;

    // For Key Press Pulse
    logic key_press_pulse_reg;
    always_comb begin
        if (key_pressed != 3'b000) begin
            key_press_pulse_reg = 1'b1;
        end else begin
            key_press_pulse_reg = 1'b0;
        end
    end
    assign key_press_pulse = key_press_pulse_reg;

    // 7-Segment Decoder Function 
    function [6:0] decode_7seg(input [3:0] val);
        case (val)
            4'h0: decode_7seg = 7'b1000000; // 0
            4'h1: decode_7seg = 7'b1111001; // 1
            4'h2: decode_7seg = 7'b0100100; // 2
            4'h3: decode_7seg = 7'b0110000; // 3
            4'h4: decode_7seg = 7'b0011001; // 4
            4'h5: decode_7seg = 7'b0010010; // 5
            4'h6: decode_7seg = 7'b0000010; // 6
            4'h7: decode_7seg = 7'b1111000; // 7
            4'h8: decode_7seg = 7'b0000000; // 8
            4'h9: decode_7seg = 7'b0010000; // 9
            4'hA: decode_7seg = 7'b0001000; // A
            4'hB: decode_7seg = 7'b0000011; // b
            4'hC: decode_7seg = 7'b1000110; // C
            4'hD: decode_7seg = 7'b0100001; // d
            4'hE: decode_7seg = 7'b0000110; // E
            4'hF: decode_7seg = 7'b0001110; // F
            default: decode_7seg = 7'b1111111; // Off
        endcase
    endfunction

    // Output Multiplexing to 7-Seg Displays
    logic [3:0] price_tens, price_units;
    logic [3:0] balance_tens, balance_units;

    assign price_tens   = (item_price / 10) % 10;
    assign price_units  = item_price % 10;
    
    assign balance_tens  = (total_balance / 10) % 10;
    assign balance_units = total_balance % 10;

    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            hex0 <= 7'b1111111;
            hex1 <= 7'b1111111;
            hex2 <= 7'b1111111;
            hex3 <= 7'b1111111;
        end else begin
            hex0 <= decode_7seg(price_units);
            hex1 <= decode_7seg(price_tens);
            hex2 <= decode_7seg(selected_row[3:0]);
            hex3 <= decode_7seg(current_state);
        end
    end

endmodule
