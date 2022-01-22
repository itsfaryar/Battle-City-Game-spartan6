library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity VGA_Square is
  port ( CLK_24MHz		: in std_logic;
			RESET				: in std_logic;
			ColorOut			: out std_logic_vector(5 downto 0); -- RED & GREEN & BLUE
			SQUAREWIDTH		: in std_logic_vector(7 downto 0);
			ScanlineX		: in std_logic_vector(10 downto 0);
			ScanlineY		: in std_logic_vector(10 downto 0)
  );
end VGA_Square;

architecture Behavioral of VGA_Square is
	type GROUND_STATE is (PLAYER,EMPTY,ICE,BRICK,WALL);
	type GROUND_TYPE is array (0 to 19, 0 to 19) of GROUND_STATE ;
	
	signal posx: integer := 0;
	signal posy: integer  := 0;
	signal ground: GROUND_TYPE := ((others=> (others=>EMPTY)));
  signal ColorOutput: std_logic_vector(5 downto 0);
  
  signal SquareX: std_logic_vector(9 downto 0) := "0000001110";  
  signal SquareY: std_logic_vector(9 downto 0) := "0000010111";  
  signal SquareXMoveDir, SquareYMoveDir: std_logic := '0';
  --constant SquareWidth: std_logic_vector(4 downto 0) := "11001";
  constant SquareXmin: std_logic_vector(9 downto 0) := "0000000001";
  signal SquareXmax: std_logic_vector(9 downto 0); -- := "1010000000"-SquareWidth;
  constant SquareYmin: std_logic_vector(9 downto 0) := "0000000001";
  signal SquareYmax: std_logic_vector(9 downto 0); -- := "0111100000"-SquareWidth;
  signal ColorSelect: std_logic_vector(2 downto 0) := "001";
  signal Prescaler: std_logic_vector(30 downto 0) := (others => '0');
  signal preskylinex,preskyliney: std_logic_vector(10 downto 0) := (others => '0');

begin
	
	ground(0,0)<=BRICK;
	ground(0,1)<=BRICK;
	ground(1,1)<=BRICK;
	ground(9,9)<=BRICK;
	ground(10,3)<=PLAYER;
	PrescalerCounter: process(CLK_24MHz, RESET)
	begin
		if RESET = '1' then
			Prescaler <= (others => '0');
			--posPreScaler  <= (others => '0');
			SquareX <= "0111000101";
			SquareY <= "0001100010";
			SquareXMoveDir <= '0';
			SquareYMoveDir <= '0';
			ColorSelect <= "001";
		elsif rising_edge(CLK_24MHz) then
			Prescaler <= Prescaler + 1;	 
			if Prescaler = "11000011010100000" then  -- Activated every 0,002 sec (2 msec)
				if SquareXMoveDir = '0' then
					if SquareX < SquareXmax then
						SquareX <= SquareX + 1;
					else
						SquareXMoveDir <= '1';
						ColorSelect <= ColorSelect(1 downto 0) & ColorSelect(2);
					end if;
				else
					if SquareX > SquareXmin then
						SquareX <= SquareX - 1;
					else
						SquareXMoveDir <= '0';
						ColorSelect <= ColorSelect(1 downto 0) & ColorSelect(2);
					end if;	 
				end if;
		  
				if SquareYMoveDir = '0' then
					if SquareY < SquareYmax then
						SquareY <= SquareY + 1;
					else
						SquareYMoveDir <= '1';
						ColorSelect <= ColorSelect(1 downto 0) & ColorSelect(2);
					end if;
				else
					if SquareY > SquareYmin then
						SquareY <= SquareY - 1;
					else
						SquareYMoveDir <= '0';
						ColorSelect <= ColorSelect(1 downto 0) & ColorSelect(2);
					end if;	 
				end if;		  
			
				Prescaler <= (others => '0');
			end if;
		end if;
	end process PrescalerCounter; 
	
	
	
--	positionx: process(ScanlineX)
--	begin
--		if ScanlineX>="0000000000" and ScanlineX<"0000110000" then
--			posx<=0;
--		elsif ScanlineX>="0011000000" and ScanlineX<"001100000" then
--			posx<=1;
--		else
--			posx <= 2;
--		end if;
--		
--	end process positionx; 
--	positiony: process(ScanlineY)
--	begin
--		if ScanlineY>="0000000000" and ScanlineY<"0000110000" then
--			posy<=0;
--		elsif ScanlineY>="0011000000" and ScanlineY<"001100000" then
--			posy<=1;
--		else
--			posy <= 2;
--		end if;
--		
--	end process positiony; 
--	ColorOutput <=		"110000" when ColorSelect(0) = '1' AND ScanlineX >= SquareX AND ScanlineY >= SquareY AND ScanlineX < SquareX+SquareWidth AND ScanlineY < SquareY+SquareWidth 
--					else	"001100" when ColorSelect(1) = '1' AND ScanlineX >= SquareX AND ScanlineY >= SquareY AND ScanlineX < SquareX+SquareWidth AND ScanlineY < SquareY+SquareWidth 
--					else	"000011" when ColorSelect(2) = '1' AND ScanlineX >= SquareX AND ScanlineY >= SquareY AND ScanlineX < SquareX+SquareWidth AND ScanlineY < SquareY+SquareWidth 
--					else	"111110";
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
				

	ColorOutput <= "101010" when (ScanlineY>="0000000000" and ScanlineY<"0000010100") or (ScanlineX>="0000000000" and ScanlineX<"0001100100") or (ScanlineY>="0111001100" and ScanlineY<"0111100000" )or (ScanlineX>="1000011100" and ScanlineX<"1010000000")
						else "000000" when ground(posy,posx)=EMPTY
						else "110000" when ground(posy,posx)=BRICK
						else "111111";
	ColorOut <= ColorOutput;
	
	SquareXmax <= "1010000000"-SquareWidth; -- (640 - SquareWidth)
	SquareYmax <= "0111100000"-SquareWidth;	-- (480 - SquareWidth)
end Behavioral;

