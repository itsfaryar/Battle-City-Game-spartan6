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
  type lutable is array (0 to 9, 0 to 9) of integer range 0 to 2;
	
	signal posx: integer := 0;
	signal posy: integer  := 0;
	signal sample_array: lutable := ((others=> (others=>0)));
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
  signal posPreScaler: std_logic_vector(7 downto 0) := (others => '0');

begin

	PrescalerCounter: process(CLK_24MHz, RESET)
	begin
		if RESET = '1' then
			Prescaler <= (others => '0');
			posPreScaler  <= (others => '0');
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
	
	position: process(CLK_24MHz)
	begin
		if rising_edge(CLK_24MHz) then
			posPreScaler <= posPreScaler + 1;
			if posPreScaler = "00110000" then
				if posx<9 then
					posx <= posx+1;
				else
					posx <=0;
					if posy<9 then
						posy <= posy+1;
					else
						posx <= 0;
						posy <= 0;
					end if;
				end if;
				posPreScaler <= (others => '0');
			end if;
		end if;
	end process position; 

	ColorOutput <=		"110000" when ColorSelect(0) = '1' AND ScanlineX >= SquareX AND ScanlineY >= SquareY AND ScanlineX < SquareX+SquareWidth AND ScanlineY < SquareY+SquareWidth 
					else	"001100" when ColorSelect(1) = '1' AND ScanlineX >= SquareX AND ScanlineY >= SquareY AND ScanlineX < SquareX+SquareWidth AND ScanlineY < SquareY+SquareWidth 
					else	"000011" when ColorSelect(2) = '1' AND ScanlineX >= SquareX AND ScanlineY >= SquareY AND ScanlineX < SquareX+SquareWidth AND ScanlineY < SquareY+SquareWidth 
					else	"111110";

	ColorOut <= ColorOutput;
	
	SquareXmax <= "1010000000"-SquareWidth; -- (640 - SquareWidth)
	SquareYmax <= "0111100000"-SquareWidth;	-- (480 - SquareWidth)
end Behavioral;

