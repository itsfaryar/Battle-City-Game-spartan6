library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.all;

entity VGA_Square is
  port ( CLK_24MHz		: in std_logic;
			RESET				: in std_logic;
			ColorOut			: out std_logic_vector(5 downto 0); -- RED & GREEN & BLUE
			ScanlineX		: in std_logic_vector(10 downto 0);
			ScanlineY		: in std_logic_vector(10 downto 0);
			sevenseg		: out bit_vector(7 downto 0);
			segout		: out bit_vector(3 downto 0);
			Key 				: in std_logic_vector(3 downto 0);
			SW 				: in std_logic_vector(7 downto 0)
			
  );
end VGA_Square;

architecture Behavioral of VGA_Square is
	type GROUND_STATE is (EMPTY,ICE,BRICK,WALL,FLAG);
	type DIRECTION is (LEFT,RIGHT,UP,DOWN);
	type GROUND_TYPE is array (0 to 19, 0 to 19) of GROUND_STATE ;
	type numberLookup is array (0 to 9) of bit_vector(7 downto 0) ;
	type POSITION_ARRAY is array (0 to 20) of integer ;
	type BITMAP is array (0 to 21, 0 to 21) of bit ;
	signal posx,posy,pl_posx,pl_posy,time_s,time_m,rand_plx: integer := 0;
	signal time_s_10,time_s_01,time_m_10,time_m_01 :integer range 0 to 9 :=0;
	signal player_dir: DIRECTION:=UP;
	signal ground: GROUND_TYPE := ((others=> (others=>EMPTY)));
	signal ColorOutput: std_logic_vector(5 downto 0);
	signal gameEnded,win,init : bit:='0';
	signal countForoneSeccond : std_logic_vector(25 downto 0) := (others => '0');
  --constant SquareWidth: std_logic_vector(4 downto 0) := "11001";
  signal sevensegmentStates : bit_vector(3 downto 0):= "0001";
  signal sevensegmentNextState : bit_vector(3 downto 0):= "0001";
   signal sevensegmentOut : bit_vector(7 downto 0):=x"c0";
  signal Prescaler: std_logic_vector(30 downto 0) := (others => '0');
  signal p_rand1: std_logic_vector(6 downto 0);
  signal p_rand2: integer range 0 to 19 :=0; --std_logic_vector(9 downto 0);
  signal pseudo_rand: std_logic_vector(31 downto 0) :=(others => '0');
  signal pseudo_rand2: std_logic_vector(31 downto 0) :=(others => '0');
	constant startPositionsX : POSITION_ARRAY := (100,122,144,166,188,210,232,254,276,296,320,342,364,386,408,430,452,474,496,518,540);
	constant startPositionsY : POSITION_ARRAY := (20,42,64,86,108,130,152,174,196,218,240,262,284,306,328,350,372,394,416,438,460);
	constant sevenSegLookup  : numberLookup := (x"c0",x"F9",x"A4",x"B0",x"99",x"92",x"82",x"F8",x"80",x"98");
	
	--------------------------bit maps
	constant tank_up : BITMAP :=(('0','0','0','0','0','0','0','0','0','0','1','1','0','0','0','0','0','0','0','0','0','0'),
('0','0','0','0','0','0','0','0','0','1','1','1','1','0','0','0','0','0','0','0','0','0'),
('0','0','0','0','0','0','0','0','0','1','1','1','1','0','0','0','0','0','0','0','0','0'),
('0','0','0','0','0','0','0','0','0','1','1','1','1','0','0','0','0','0','0','0','0','0'),
('0','0','0','0','0','0','0','0','0','1','1','1','1','0','0','0','0','0','0','0','0','0'),
('0','0','0','0','0','0','0','0','0','1','1','1','1','0','0','0','0','0','0','0','0','0'),
('0','0','0','0','0','0','0','0','0','1','1','1','1','0','0','0','0','0','0','0','0','0'),
('0','0','0','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','0','0','0'),
('0','0','0','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','0','0','0'),
('0','0','0','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','0','0','0'),
('0','0','0','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','0','0','0'),
('0','0','0','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','0','0','0'),
('0','0','0','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','0','0','0'),
('0','0','0','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','0','0','0'),
('0','0','0','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','0','0','0'),
('0','0','0','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','0','0','0'),
('0','0','0','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','0','0','0'),
('0','0','0','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','0','0','0'),
('0','0','0','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','0','0','0'),
('0','0','0','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','0','0','0'),
('0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0'),
('0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0'));

constant tank_down : BITMAP := (('0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0'),
('0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0'),
('0','0','0','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','0','0','0'),
('0','0','0','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','0','0','0'),
('0','0','0','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','0','0','0'),
('0','0','0','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','0','0','0'),
('0','0','0','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','0','0','0'),
('0','0','0','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','0','0','0'),
('0','0','0','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','0','0','0'),
('0','0','0','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','0','0','0'),
('0','0','0','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','0','0','0'),
('0','0','0','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','0','0','0'),
('0','0','0','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','0','0','0'),
('0','0','0','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','0','0','0'),
('0','0','0','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','0','0','0'),
('0','0','0','0','0','0','0','0','0','1','1','1','1','0','0','0','0','0','0','0','0','0'),
('0','0','0','0','0','0','0','0','0','1','1','1','1','0','0','0','0','0','0','0','0','0'),
('0','0','0','0','0','0','0','0','0','1','1','1','1','0','0','0','0','0','0','0','0','0'),
('0','0','0','0','0','0','0','0','0','1','1','1','1','0','0','0','0','0','0','0','0','0'),
('0','0','0','0','0','0','0','0','0','1','1','1','1','0','0','0','0','0','0','0','0','0'),
('0','0','0','0','0','0','0','0','0','1','1','1','1','0','0','0','0','0','0','0','0','0'),
('0','0','0','0','0','0','0','0','0','0','1','1','0','0','0','0','0','0','0','0','0','0'));

constant tank_left : BITMAP := (('0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0'),
('0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0'),
('0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0'),
('0','0','0','0','0','0','0','1','1','1','1','1','1','1','1','1','1','1','1','1','0','0'),
('0','0','0','0','0','0','0','1','1','1','1','1','1','1','1','1','1','1','1','1','0','0'),
('0','0','0','0','0','0','0','1','1','1','1','1','1','1','1','1','1','1','1','1','0','0'),
('0','0','0','0','0','0','0','1','1','1','1','1','1','1','1','1','1','1','1','1','0','0'),
('0','0','0','0','0','0','0','1','1','1','1','1','1','1','1','1','1','1','1','1','0','0'),
('0','0','0','0','0','0','0','1','1','1','1','1','1','1','1','1','1','1','1','1','0','0'),
('0','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','0','0'),
('1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','0','0'),
('1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','0','0'),
('0','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','0','0'),
('0','0','0','0','0','0','0','1','1','1','1','1','1','1','1','1','1','1','1','1','0','0'),
('0','0','0','0','0','0','0','1','1','1','1','1','1','1','1','1','1','1','1','1','0','0'),
('0','0','0','0','0','0','0','1','1','1','1','1','1','1','1','1','1','1','1','1','0','0'),
('0','0','0','0','0','0','0','1','1','1','1','1','1','1','1','1','1','1','1','1','0','0'),
('0','0','0','0','0','0','0','1','1','1','1','1','1','1','1','1','1','1','1','1','0','0'),
('0','0','0','0','0','0','0','1','1','1','1','1','1','1','1','1','1','1','1','1','0','0'),
('0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0'),
('0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0'),
('0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0'));

constant tank_right : BITMAP := (('0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0'),
('0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0'),
('0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0'),
('0','0','1','1','1','1','1','1','1','1','1','1','1','1','1','0','0','0','0','0','0','0'),
('0','0','1','1','1','1','1','1','1','1','1','1','1','1','1','0','0','0','0','0','0','0'),
('0','0','1','1','1','1','1','1','1','1','1','1','1','1','1','0','0','0','0','0','0','0'),
('0','0','1','1','1','1','1','1','1','1','1','1','1','1','1','0','0','0','0','0','0','0'),
('0','0','1','1','1','1','1','1','1','1','1','1','1','1','1','0','0','0','0','0','0','0'),
('0','0','1','1','1','1','1','1','1','1','1','1','1','1','1','0','0','0','0','0','0','0'),
('0','0','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','0'),
('0','0','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1'),
('0','0','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1'),
('0','0','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','0'),
('0','0','1','1','1','1','1','1','1','1','1','1','1','1','1','0','0','0','0','0','0','0'),
('0','0','1','1','1','1','1','1','1','1','1','1','1','1','1','0','0','0','0','0','0','0'),
('0','0','1','1','1','1','1','1','1','1','1','1','1','1','1','0','0','0','0','0','0','0'),
('0','0','1','1','1','1','1','1','1','1','1','1','1','1','1','0','0','0','0','0','0','0'),
('0','0','1','1','1','1','1','1','1','1','1','1','1','1','1','0','0','0','0','0','0','0'),
('0','0','1','1','1','1','1','1','1','1','1','1','1','1','1','0','0','0','0','0','0','0'),
('0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0'),
('0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0'),
('0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0'));




begin
initialize: process(CLK_24MHz, RESET)
variable x,y : integer :=0;
		function lfsr32(x : std_logic_vector(31 downto 0)) return std_logic_vector is
				begin
				return x(30 downto 0) & (x(0) xnor x(1) xnor x(21) xnor x(31));
			end function;
	begin
		if RESET = '1' then
			init <= '1';
			x:=0;
			y:=0;
			ground <= ((others=> (others=>EMPTY)));
		elsif rising_edge(CLK_24MHz) then
		
			if init='1' then
				
				pseudo_rand <= lfsr32(pseudo_rand);
				p_rand1 <= not pseudo_rand(6 downto 0);
				if p_rand1>="0000000" and p_rand1<"0000111" then
					ground(y,x)<=ICE;
				elsif p_rand1>="0000111" and p_rand1<"0010111" then
					ground(y,x)<=WALL;
				elsif p_rand1>="0010111" and p_rand1<"0110111" then
					ground(y,x)<=BRICK;
				else
					ground(y,x)<=EMPTY;
				end if;
--				p_rand1 <= pseudo_rand(2 downto 0);
--				if p_rand1="00"  then
--					ground(y,x)<=EMPTY;
--				elsif p_rand1="01" then
--					ground(y,x)<=BRICK;
--				elsif p_rand1="10"  then
--					ground(y,x)<=WALL;
--				else
--					ground(y,x)<=ICE;
--				end if;
				if x<19 then
					x:= x+1;
				else 
					x:=0;
					if y<19 then
						y:= y+1;
					else
						y:=0;
						init <= '0';
						ground(19, CONV_INTEGER(pseudo_rand(4 downto 0))rem 19) <= FLAG;
						
					end if;
				end if;
--			ground(19,CONV_INTEGER(pseudo_rand(10 downto 5))rem 19) <= FLAG;
			
			end if;
		end if;
	end process initialize; 
		
 process(sevensegmentStates )
	 begin
		sevensegmentNextState<="1110";
		case sevensegmentStates is
		
			when "1110" =>
			sevensegmentNextState<="1101";
			sevensegmentOut <= sevenSegLookup(time_m_10);
			when "1101" =>
			sevensegmentNextState<="1011";
			sevensegmentOut <= sevenSegLookup(time_m_01);
			when "1011" =>
			sevensegmentNextState<="0111";
			sevensegmentOut <= sevenSegLookup(time_s_10);
			when "0111" =>
			sevensegmentNextState<="1110";
			sevensegmentOut <= sevenSegLookup(time_s_01);
			when others =>
			sevensegmentOut <= sevenSegLookup(0);
		end case;
	end process;	
	
	svnsegmentNextState: process(CLK_24MHz, RESET)
		variable counter : integer range 0 to 5000 :=0;
	begin
		if RESET = '1' then
			sevensegmentStates<="1110";
		elsif rising_edge(CLK_24MHz) then
			
			 counter := counter +1;
			 if (counter = 4999) then 
				 counter :=0;
			    sevensegmentStates<=sevensegmentNextState;
			 end if;
		end if;
	end process svnsegmentNextState; 
	segout <= sevensegmentStates;
	sevenseg <= sevensegmentOut;
	
	timer: process(CLK_24MHz, RESET)
	begin
		if RESET = '1' then
			countForoneSeccond <= (others => '0');
			time_s <= 0;
			time_s_10 <= 0;
			time_s_01 <= 0;
			time_m_10 <= 0;
			time_m_01 <= 0;
			time_m <= 0;
			gameEnded<= '0';
			win <= '0';
		elsif rising_edge(CLK_24MHz) then
			if init='0' then
				if ground(pl_posy,pl_posx)=FLAG then
					gameEnded <= '1';
				end if;
				if gameEnded='0' then
					countForoneSeccond <= countForoneSeccond+1;
					if countForoneSeccond = "1011011100011011000000000" then  -- Activated every 0,002 sec (2 msec)
						if time_s<59 then
							time_s <= time_s+1;
							if time_s_01<9 then
								time_s_01<= time_s_01+1;
							else
								time_s_01<=0;
								time_s_10<=time_s_10+1;
							end if;
						else
							time_s <= 0;
							time_s_01<=0;
							time_s_10<=0;
							if time_m<=59 then
								time_m<=time_m+1;
								if time_m_01<9 then
									time_m_01<= time_m_01+1;
								else
									time_m_01<=0;
									time_m_10<=time_m_10;
								end if;
							else
								time_m <=0;
								time_m_01<=0;
								time_m_10<=0;
								gameEnded <= '1';
							end if;
							
						end if;
						countForoneSeccond <= (others => '0');
					end if;
					elsif time_m<10 then
						win <= '1';
						
				end if;
			end if;
		end if;
	end process timer; 

	
	PrescalerCounter: process(CLK_24MHz, RESET)
		function lfsr32(x : std_logic_vector(31 downto 0)) return std_logic_vector is
				begin
				return x(30 downto 0) & (x(0) xnor x(1) xnor x(21) xnor x(31));
			end function;
	begin
		if RESET = '1' then
			
			Prescaler <= (others => '0');
			pseudo_rand2 <= lfsr32(pseudo_rand2);
	      pl_posx <= CONV_INTEGER(pseudo_rand2(4 downto 0))rem 19;
			pl_posy<=0;
			
			player_dir <= DOWN;
			
			
		elsif rising_edge(CLK_24MHz) then
			if gameEnded='0' then
				Prescaler <= Prescaler + 1;
			
				if Prescaler = "100110001001011010000000" then  -- Activated every 0,002 sec (2 msec)
					 if key(0)='0' then
						if pl_posy>0 and (ground(pl_posy-1,pl_posx)=EMPTY or ground(pl_posy-1,pl_posx)=ICE) then
							pl_posy<=pl_posy-1;
							player_dir<=UP;
						else
							player_dir<=DOWN;
						end if;
					elsif key(3)='0' then
						if pl_posy<19 and (ground(pl_posy+1,pl_posx)=EMPTY or ground(pl_posy+1,pl_posx)=ICE) then
							pl_posy<=pl_posy+1;
							player_dir<= DOWN;
						else
							player_dir<= UP;
						end if;
					elsif key(1)='0' then
						if pl_posx<19 and (ground(pl_posy,pl_posx+1)=EMPTY or ground(pl_posy,pl_posx+1)=ICE)then
							pl_posx<=pl_posx+1;
							player_dir<= RIGHT;
						else
							player_dir<= LEFT;
						end if;
						elsif key(2)='0' then
						if pl_posx>0 and (ground(pl_posy,pl_posx-1)=EMPTY or ground(pl_posy,pl_posx-1)=ICE) then
							pl_posx<=pl_posx-1;
							player_dir<= LEFT;
						else
							player_dir<= RIGHT;
						end if;
					end if;
					
					Prescaler <= (others => '0');
				end if;
				end if;
			
		end if;
	end process PrescalerCounter; 


	posx <= 0 when ScanlineX>=conv_std_logic_vector(100,10) and ScanlineX<conv_std_logic_vector(122,10)
				else 1 when ScanlineX>=conv_std_logic_vector(122,10) and ScanlineX<conv_std_logic_vector(144,10)
				else 2 when ScanlineX>=conv_std_logic_vector(144,10) and ScanlineX<conv_std_logic_vector(166,10)
				else 3 when ScanlineX>=conv_std_logic_vector(166,10) and ScanlineX<conv_std_logic_vector(188,10)
				else 4 when ScanlineX>=conv_std_logic_vector(188,10) and ScanlineX<conv_std_logic_vector(210,10)
				else 5 when ScanlineX>=conv_std_logic_vector(210,10) and ScanlineX<conv_std_logic_vector(232,10)
				else 6 when ScanlineX>=conv_std_logic_vector(232,10) and ScanlineX<conv_std_logic_vector(254,10)
				else 7 when ScanlineX>=conv_std_logic_vector(254,10) and ScanlineX<conv_std_logic_vector(276,10)
				else 8 when ScanlineX>=conv_std_logic_vector(276,10) and ScanlineX<conv_std_logic_vector(298,10)
				else 9 when ScanlineX>=conv_std_logic_vector(298,10) and ScanlineX<conv_std_logic_vector(320,10)
				else 10 when ScanlineX>=conv_std_logic_vector(320,10) and ScanlineX<conv_std_logic_vector(342,10)
				else 11 when ScanlineX>=conv_std_logic_vector(342,10) and ScanlineX<conv_std_logic_vector(364,10)
				else 12 when ScanlineX>=conv_std_logic_vector(364,10) and ScanlineX<conv_std_logic_vector(386,10)
				else 13 when ScanlineX>=conv_std_logic_vector(386,10) and ScanlineX<conv_std_logic_vector(408,10)
				else 14 when ScanlineX>=conv_std_logic_vector(408,10) and ScanlineX<conv_std_logic_vector(430,10)
				else 15 when ScanlineX>=conv_std_logic_vector(430,10) and ScanlineX<conv_std_logic_vector(452,10)
				else 16 when ScanlineX>=conv_std_logic_vector(452,10) and ScanlineX<conv_std_logic_vector(474,10)
				else 17 when ScanlineX>=conv_std_logic_vector(474,10) and ScanlineX<conv_std_logic_vector(496,10)
				else 18 when ScanlineX>=conv_std_logic_vector(496,10) and ScanlineX<conv_std_logic_vector(518,10)
				else 19 when ScanlineX>=conv_std_logic_vector(518,10) and ScanlineX<conv_std_logic_vector(540,10);
				

				
	posy <= 0 when ScanlineY>=conv_std_logic_vector(20,10) and ScanlineY<conv_std_logic_vector(42,10)
				else 1 when ScanlineY>=conv_std_logic_vector(42,10) and ScanlineY<conv_std_logic_vector(64,10)
				else 2 when ScanlineY>=conv_std_logic_vector(64,10) and ScanlineY<conv_std_logic_vector(86,10)
				else 3 when ScanlineY>=conv_std_logic_vector(86,10) and ScanlineY<conv_std_logic_vector(108,10)
				else 4 when ScanlineY>=conv_std_logic_vector(108,10) and ScanlineY<conv_std_logic_vector(130,10)
				else 5 when ScanlineY>=conv_std_logic_vector(130,10) and ScanlineY<conv_std_logic_vector(152,10)
				else 6 when ScanlineY>=conv_std_logic_vector(152,10) and ScanlineY<conv_std_logic_vector(174,10)
				else 7 when ScanlineY>=conv_std_logic_vector(174,10) and ScanlineY<conv_std_logic_vector(196,10)
				else 8 when ScanlineY>=conv_std_logic_vector(196,10) and ScanlineY<conv_std_logic_vector(218,10)
				else 9 when ScanlineY>=conv_std_logic_vector(218,10) and ScanlineY<conv_std_logic_vector(240,10)
				else 10 when ScanlineY>=conv_std_logic_vector(240,10) and ScanlineY<conv_std_logic_vector(262,10)
				else 11 when ScanlineY>=conv_std_logic_vector(262,10) and ScanlineY<conv_std_logic_vector(284,10)
				else 12 when ScanlineY>=conv_std_logic_vector(284,10) and ScanlineY<conv_std_logic_vector(306,10)
				else 13 when ScanlineY>=conv_std_logic_vector(306,10) and ScanlineY<conv_std_logic_vector(328,10)
				else 14 when ScanlineY>=conv_std_logic_vector(328,10) and ScanlineY<conv_std_logic_vector(350,10)
				else 15 when ScanlineY>=conv_std_logic_vector(350,10) and ScanlineY<conv_std_logic_vector(372,10)
				else 16 when ScanlineY>=conv_std_logic_vector(372,10) and ScanlineY<conv_std_logic_vector(394,10)
				else 17 when ScanlineY>=conv_std_logic_vector(394,10) and ScanlineY<conv_std_logic_vector(416,10)
				else 18 when ScanlineY>=conv_std_logic_vector(416,10) and ScanlineY<conv_std_logic_vector(438,10)
				else 19 when ScanlineY>=conv_std_logic_vector(438,10) and ScanlineY<conv_std_logic_vector(460,10);
				
---------methode 1
	ColorOutput <= "101010" when (ScanlineY>="0000000000" and ScanlineY<"0000010100") or (ScanlineX>="0000000000" and ScanlineX<"0001100100") or (ScanlineY>="0111001100" and ScanlineY<"0111100000" )or (ScanlineX>="1000011100" and ScanlineX<"1010000000")
						else "001000" when win='1'
						else "100101" when player_dir=UP and pl_posx=posx and pl_posy=posy and tank_up(CONV_INTEGER(ScanlineY-conv_std_logic_vector(startPositionsY(posy),10)),CONV_INTEGER(ScanlineX-conv_std_logic_vector(startPositionsX(posx),10)))='1'
						else "100101" when player_dir=DOWN and pl_posx=posx and pl_posy=posy and tank_down(CONV_INTEGER(ScanlineY-conv_std_logic_vector(startPositionsY(posy),10)),CONV_INTEGER(ScanlineX-conv_std_logic_vector(startPositionsX(posx),10)))='1'
						else "100101" when player_dir=LEFT and pl_posx=posx and pl_posy=posy and tank_left(CONV_INTEGER(ScanlineY-conv_std_logic_vector(startPositionsY(posy),10)),CONV_INTEGER(ScanlineX-conv_std_logic_vector(startPositionsX(posx),10)))='1'
						else "100101" when player_dir=RIGHT and pl_posx=posx and pl_posy=posy and tank_right(CONV_INTEGER(ScanlineY-conv_std_logic_vector(startPositionsY(posy),10)),CONV_INTEGER(ScanlineX-conv_std_logic_vector(startPositionsX(posx),10)))='1'
						
						else "000000" when ground(posy,posx)=EMPTY
						else "000001" when ground(posy,posx)=ICE
						else "011000" when ground(posy,posx)=BRICK
						else "001100" when ground(posy,posx)=FLAG
						else "111111";
	
-----------methode 2: replaced with code above	
--	ColorProcess: process(ScanlineX,ScanlineY)
--	begin
--		if (ScanlineY>="0000000000" and ScanlineY<"0000010100") or (ScanlineX>="0000000000" and ScanlineX<"0001100100") or (ScanlineY>="0111001100" and ScanlineY<"0111100000" )or (ScanlineX>="1000011100" and ScanlineX<"1010000000") then
--			ColorOutput <= "101010";
--		elsif ground(posy,posx)=EMPTY then
--			ColorOutput <= "000000";
--		elsif ground(posy,posx)=BRICK then
--			ColorOutput <= "011000";
--		else
--			ColorOutput <= "000000";
--		end if;
--		if pl_posx=posx and pl_posy=posy then
--			--if tank(CONV_INTEGER(ScanlineY-std_logic_vector((to_unsigned(posy,10)* "0000010110"))-"0000010100"),CONV_INTEGER(ScanlineX-std_logic_vector((to_unsigned(posx,10)* "0000010110"))-"0001100100"))='1' then
--			if tank(CONV_INTEGER(ScanlineY-conv_std_logic_vector(startPositionsY(posy),10)),CONV_INTEGER(ScanlineX-conv_std_logic_vector(startPositionsX(posx),10)))='1' then
--				ColorOutput <= "100101";
--			end if;
--		end if;
--	end process ColorProcess; 
	ColorOut <= ColorOutput;

end Behavioral;

