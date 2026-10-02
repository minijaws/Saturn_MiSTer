// Sega Saturn 6-Player Multitap (HSS-0111) emulation.
//
// Presents six standard digital pads to the SMPC through the 3-wire
// TH/TR/TL handshake, exactly as the real adapter does. The SMPC firmware
// (running on the HMCS400 core) does all the parsing; this module only has
// to answer the handshake with the right nibble stream.
//
// Protocol (after Mednafen ss/input/multitap.cpp):
//   TH high            : reset. TL=1, D[3:0]=0001 (reads as ID 5 = 3-wire device)
//   TH low, TR != TL   : put next nibble on D[3:0], toggle TL
//
//   Header             : 4, 1, 6, 0            (multitap ID 0x41, 6 ports)
//   Per port (x6)      : 0, 2, DIR, SACB, RXYZ, L111   (digital pad, ID 0x02)
//   Footer             : 0, 1
//
// After the footer the tap holds its outputs until TH goes high again.
//
// PADn uses the same active-low layout as HPS2PAD's JOYx:
//   [15:12] TH0/TR1 nibble (R,L,D,U)
//   [11: 8] TH1/TR0 nibble (Start,A,C,B)
//   [ 7: 4] TH0/TR0 nibble (R,X,Y,Z)
//   [    3] L
//
// Every port always reports a connected pad: MiSTer cannot tell whether a
// USB controller is assigned to a given player slot, and an idle pad is
// harmless to games.

module SaturnMultitap (
	input             CLK,
	input             RST_N,
	input             CE,

	input             TH,
	input             TR,
	output reg        TL,
	output reg [ 3:0] DATA,

	input      [15:0] PAD0,
	input      [15:0] PAD1,
	input      [15:0] PAD2,
	input      [15:0] PAD3,
	input      [15:0] PAD4,
	input      [15:0] PAD5
);

	localparam PH_HEADER = 2'd0;
	localparam PH_PORTS  = 2'd1;
	localparam PH_FOOTER = 2'd2;
	localparam PH_DONE   = 2'd3;

	reg [1:0] phase;
	reg [2:0] cnt;    // nibble within header / port / footer
	reg [2:0] port;

	reg [15:0] pad;
	always_comb begin
		case (port)
			3'd0:    pad = PAD0;
			3'd1:    pad = PAD1;
			3'd2:    pad = PAD2;
			3'd3:    pad = PAD3;
			3'd4:    pad = PAD4;
			default: pad = PAD5;
		endcase
	end

	reg [3:0] nib;
	always_comb begin
		case (phase)
			PH_HEADER:
				case (cnt)
					3'd0:    nib = 4'h4;
					3'd1:    nib = 4'h1;
					3'd2:    nib = 4'h6;
					default: nib = 4'h0;
				endcase
			PH_PORTS:
				case (cnt)
					3'd0:    nib = 4'h0;
					3'd1:    nib = 4'h2;
					3'd2:    nib = pad[15:12];
					3'd3:    nib = pad[11: 8];
					3'd4:    nib = pad[ 7: 4];
					default: nib = {pad[3], 3'b111};
				endcase
			PH_FOOTER:
				nib = (cnt == 3'd0) ? 4'h0 : 4'h1;
			default:
				nib = 4'h1;
		endcase
	end

	always @(posedge CLK or negedge RST_N) begin
		if (!RST_N) begin
			phase <= PH_HEADER;
			cnt   <= '0;
			port  <= '0;
			TL    <= 1'b1;
			DATA  <= 4'h1;
		end else if (CE) begin
			if (TH) begin
				phase <= PH_HEADER;
				cnt   <= '0;
				port  <= '0;
				TL    <= 1'b1;
				DATA  <= 4'h1;
			end else if (TR != TL && phase != PH_DONE) begin
				DATA <= nib;
				TL   <= ~TL;

				case (phase)
					PH_HEADER: begin
						if (cnt == 3'd3) begin phase <= PH_PORTS; cnt <= '0; port <= '0; end
						else cnt <= cnt + 3'd1;
					end
					PH_PORTS: begin
						if (cnt == 3'd5) begin
							cnt <= '0;
							if (port == 3'd5) phase <= PH_FOOTER;
							else              port  <= port + 3'd1;
						end
						else cnt <= cnt + 3'd1;
					end
					PH_FOOTER: begin
						if (cnt == 3'd1) phase <= PH_DONE;
						else             cnt   <= cnt + 3'd1;
					end
					default: ;
				endcase
			end
		end
	end

endmodule
