module stack_behaviour_normal(
    inout wire[3:0] IO_DATA, 
    input wire RESET, 
    input wire CLK, 
    input wire[1:0] COMMAND,
    input wire[2:0] INDEX
    ); 
     
    reg[3:0] stack[4:0];
    reg[2:0] ptr;
    reg[2:0] prev_ptr;
    reg[3:0] out;
    
    assign IO_DATA = (CLK == 1 && (COMMAND == 2 || COMMAND == 3)) ? out : 4'bzzzz;

    always @(posedge RESET) begin
            stack[0] = 0;
            stack[1] = 0;
            stack[2] = 0;
            stack[3] = 0;
            stack[4] = 0;
            ptr = 0;
            prev_ptr = 0;
            out = 0;
    end

    always @(negedge CLK) begin
        if (RESET == 0) begin
            if (COMMAND == 1) begin
                if (ptr == 4) begin
                    ptr = 3;
                end else begin
                    ptr = (ptr + 4) % 5;
                end
            end else if (COMMAND == 2) begin 
                prev_ptr = ptr;
                ptr = (ptr + 1) % 5;
            end 
        end
    end
    
    always @(posedge CLK) begin
        if (RESET == 0) begin
            if (COMMAND == 1) begin
                stack[ptr] = IO_DATA;
            end else if (COMMAND == 2) begin 
                out = stack[prev_ptr];
            end else if (COMMAND == 3) begin 
                if (ptr == 4 && (INDEX % 5) == 4) begin
                    out = stack[3];
                end else begin
                    out = stack[(ptr + INDEX % 5) % 5];
                end
            end
        end
    end

endmodule;