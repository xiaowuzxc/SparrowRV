module dpram #(
    parameter RAM_WIDTH = 32,                       // Specify RAM data width
    parameter RAM_DEPTH = 65536                     // Specify RAM depth (number of entries)

) (
    input [clogb2(RAM_DEPTH-1)-1:0] addra,  // Port A address bus, width determined from RAM_DEPTH
    input [clogb2(RAM_DEPTH-1)-1:0] addrb,  // Port B address bus, width determined from RAM_DEPTH
    input [RAM_WIDTH-1:0] dina,           // Port A RAM input data
    input [RAM_WIDTH-1:0] dinb,           // Port B RAM input data
    input clka,                           // Clock
    input wea,                            // Port A write enable
    input web,                            // Port B write enable
    input [3:0] wema,
    input [3:0] wemb,
    input ena,                            // Port A RAM Enable, for additional power savings, disable port when not in use
    input enb,                            // Port B RAM Enable, for additional power savings, disable port when not in use
    input rsta,                           // Port A output reset (does not affect memory contents)
    input rstb,                           // Port B output reset (does not affect memory contents)
    input regcea,                         // Port A output register enable
    input regceb,                         // Port B output register enable
    output [RAM_WIDTH-1:0] douta,         // Port A RAM output data
    output [RAM_WIDTH-1:0] doutb          // Port B RAM output data
);

reg [RAM_WIDTH-1:0] BRAM [0:RAM_DEPTH-1];
reg [RAM_WIDTH-1:0] ram_data_a = {RAM_WIDTH{1'b0}};
reg [RAM_WIDTH-1:0] ram_data_b = {RAM_WIDTH{1'b0}};



always @(posedge clka)
    if (ena) begin
        if (wea) begin
            if(wema[0])
                BRAM[addra][7:0] <= dina[7:0];
            if(wema[1])
                BRAM[addra][15:8] <= dina[15:8];
            if(wema[2])
                BRAM[addra][23:16] <= dina[23:16];
            if(wema[3])
                BRAM[addra][31:24] <= dina[31:24];
        end
        else begin
            ram_data_a <= BRAM[addra];
        end
    end

always @(posedge clka)
    if (enb) begin
        if (web) begin
            if(wemb[0])
                BRAM[addrb][7:0] <= dinb[7:0];
            if(wemb[1])
                BRAM[addrb][15:8] <= dinb[15:8];
            if(wemb[2])
                BRAM[addrb][23:16] <= dinb[23:16];
            if(wemb[3])
                BRAM[addrb][31:24] <= dinb[31:24];
        end
        else begin
            ram_data_b <= BRAM[addrb];
        end
    end

assign douta = ram_data_a;
assign doutb = ram_data_b;


//  The following function calculates the address width based on specified RAM depth
function integer clogb2;
    input integer depth;
        for (clogb2=0; depth>0; clogb2=clogb2+1)
            depth = depth >> 1;
endfunction



endmodule