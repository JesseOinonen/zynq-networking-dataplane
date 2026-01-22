module axi_lite_slave (
    input  logic        clk,
    input  logic        rst_n,
    // Write address signals (AW channel)
    input  logic [31:0] AWADDR,  
    input  logic [ 2:0] AWPROT,  
    input  logic        AWVALID, 
    output logic        AWREADY, 
    // Write data (W channel)
    input  logic [31:0] WDATA,   
    input  logic [ 3:0] WSTRB,   
    input  logic        WVALID,  
    output logic        WREADY,  
    // Write response (B channel)
    input  logic        BREADY,  
    output logic        BVALID,  
    output logic [ 1:0] BRESP,   
    // Read address (AR channel)
    input  logic [31:0] ARADDR,  
    input  logic [ 2:0] ARPROT,  
    input  logic        ARVALID, 
    output logic        ARREADY, 
    // Read data (R channel)
    input  logic        RREADY,  
    output logic        RVALID,  
    output logic [31:0] RDATA,   
    output logic [ 1:0] RRESP
);

// FSM states
typedef enum logic [1:0] {IDLE, WRITE, READ, RESP} state_t;
state_t state_w, next_state_w, state_r, next_state_r;

// State update
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        state_w <= IDLE;
        state_r <= IDLE;
    end
    else begin
        state_w <= next_state_w;
        state_r <= next_state_r;
    end
end

// Write FSM
always_comb begin
    // Default assignments
    AWREADY = 0;
    WREADY  = 0;
    BVALID  = 0;
    BRESP   = 2'b00;
    next_state_w = state_w;

    case(state_w)
        IDLE: begin
            if(AWVALID && WVALID) begin
                AWREADY = 1;
                WREADY  = 1;
                next_state_w = WRITE;
            end
        end
        WRITE: begin
            // Capture address/data
            // Move to RESP
            next_state_w = RESP;
        end
        RESP: begin
            BVALID = 1;
            if(BREADY) next_state_w = IDLE;
        end
    endcase
end

// Read FSM
always_comb begin
    // Default assignments

end

endmodule  