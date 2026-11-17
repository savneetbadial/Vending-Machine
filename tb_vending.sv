module tb_vending ();
    // Testbench signals
    logic clk;
    logic reset_n;
    logic [9:0]   switches;
    logic [2:0]   keys;
    logic [3:0]   current_state;
    logic [7:0]   item_price;
    logic [7:0]   total_balance;
    logic [7:0]   change_due;
    
    logic [3:0]   selected_row;
    logic [3:0]   selected_col;
    logic [6:0]   hex0;
    logic [6:0]   hex1;
    logic [6:0]   hex2;
    logic [6:0]   hex3;
    logic         key_press_pulse;

    // Instantiate the Unit Under Test (UUT)
    vending_io_display uut (
        .clk(clk),
        .reset_n(reset_n),
        .switches(switches),
        .keys(keys),
        .current_state(current_state),
        .item_price(item_price),
        .total_balance(total_balance),
        .change_due(change_due),
        .selected_row(selected_row),
        .selected_col(selected_col),
        .hex0(hex0),
        .hex1(hex1),
        .hex2(hex2),
        .hex3(hex3),
        .key_press_pulse(key_press_pulse)
    );

    // 50 MHz Clock Generation (20ns period)
    always #10 clk = ~clk;

    // Stimulus process
    initial begin
        // Initialize signals
        clk           = 0;
        reset_n       = 0;         // Assert active-low reset
        switches      = 10'h000;
        keys          = 3'b111;    // Active-low buttons unpressed (high)
        current_state = 4'h0;
        item_price    = 8'd0;
        total_balance = 8'd0;
        change_due    = 8'd0;

        // Hold reset for 50 ns
        #50;
        reset_n = 1;               // Release reset
        #30;

        // Test 1: Switch Row/Column Selection
        $display("Test 1: Testing switch decoding for 2-D array...");
        switches = 10'b0101001111; // Col = 5 (switches[7:4]), Row = 15 (switches[3:0])
        #40;
        
        // Test 2: Price and State Display Rendering
        $display("Test 2: Setting item price and FSM state...");
        item_price    = 8'd45;     // Should split into tens=4, units=5
        total_balance = 8'd50;
        current_state = 4'h3;      // Mock state 3
        #40;

        // Test 3: Button Press & Edge Detection (KEY0)
        $display("Test 3: Simulating KEY0 press...");
        keys[0] = 1'b0;            // Press KEY0 (active low)
        #40;
        keys[0] = 1'b1;            // Release KEY0
        #40;

        // Test 4: Simulating KEY1 Press
        $display("Test 4: Simulating KEY1 press...");
        keys[1] = 1'b0;            // Press KEY1
        #40;
        keys[1] = 1'b1;            // Release KEY1
        #40;

        // Test 5: Simulating Multiple/Simultaneous Keys
        $display("Test 5: Simulating KEY2 press...");
        keys[2] = 1'b0;            // Press KEY2
        #40;
        keys[2] = 1'b1;            // Release KEY2
        #40;

        $display("Simulation completed successfully.");
    end

    initial begin
        $monitor("Time=%0t ns | Reset=%b | Switches=%h | Keys=%b | State=%h | Price=%0d | KeyPulse=%b | HEX0=%b", 
                 $time, reset_n, switches, keys, current_state, item_price, key_press_pulse, hex0);
    end

endmodule



