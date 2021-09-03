-- Autor reseni: VOJTECH JURKA, XJURKA08

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity ledc8x8 is
port ( -- Sem doplnte popis rozhrani obvodu.
        SMCLK : in std_logic;
		RESET : in std_logic;
		ROW : out std_logic_vector(0 to 7);
		LED : out std_logic_vector(0 to 7)

);
end ledc8x8;

architecture main of ledc8x8 is

    -- Sem doplnte definice vnitrnich signalu.

	signal ce : std_logic := '0';
	signal ce_cnt : std_logic_vector(11 downto 0) := (others => '0');
	signal stav_cnt : std_logic_vector(22 downto 0) := (others => '0');

	signal rows_active : std_logic_vector(0 to 7) := "10000000";
	signal leds_active : std_logic_vector(0 to 7) := (others => '1');


begin

    --citac na snizeni frekvence
    ce_generator: process(SMCLK, RESET)
	begin
		if RESET = '1' then
			ce_cnt <= (others => '0');
		elsif SMCLK'event and SMCLK = '1' then

		    if ce_cnt = "111000010000" then
		        ce <= '1';
		        ce_cnt <= (others => '0');
		    else
		        ce <= '0';
		    end if;

			ce_cnt <= ce_cnt + 1;
		end if;

	end process ce_generator;

	--rotace radku
	rows_activate: process(SMCLK, RESET, ce)
	begin
		if RESET = '1' then
			rows_active <= "10000000";
		elsif SMCLK'event and SMCLK = '1' then
			if ce = '1' then
				rows_active <= rows_active(7) & rows_active(0 to 6);
			end if;
		end if;
	end process rows_activate;

	ROW <= rows_active; --nastaveni aktualniho radku

	--zmena stavu displeje
	zmena_stavu: process(SMCLK, RESET)
	begin
		if RESET = '1' then
			stav_cnt <= (others => '0');
		elsif SMCLK'event and SMCLK = '1' then
		    if stav_cnt < "11100001111111111111111" then --pricitej, dokud neprekkroci dobu 1s (posledni stav)
                stav_cnt <= stav_cnt + 1;
		    end if;
		end if;
	end process zmena_stavu;


	--vyber aktivnich ledek v radku

	leds_activate: process(rows_active, stav_cnt)
	begin
	    if stav_cnt < "1110000100000000000001" then --do pul sekundy

            case rows_active is
                when "10000000" => leds_active <= "01110111";
                when "01000000" => leds_active <= "01110111";
                when "00100000" => leds_active <= "10101111";
                when "00010000" => leds_active <= "10101110";
                when "00001000" => leds_active <= "11011110";
                when "00000100" => leds_active <= "11111110";
                when "00000010" => leds_active <= "11110110";
                when "00000001" => leds_active <= "11111001";
                when others     => leds_active <= "11111111";
            end case;

	    elsif stav_cnt < "11100001000000000000000" then --po pul sekunde

	        case rows_active is
                when "10000000" => leds_active <= "11111111";
                when "01000000" => leds_active <= "11111111";
                when "00100000" => leds_active <= "11111111";
                when "00010000" => leds_active <= "11111111";
                when "00001000" => leds_active <= "11111111";
                when "00000100" => leds_active <= "11111111";
                when "00000010" => leds_active <= "11111111";
                when "00000001" => leds_active <= "11111111";
                when others     => leds_active <= "11111111";
            end case;

	    else --po sekunde

	        case rows_active is
                when "10000000" => leds_active <= "01110111";
                when "01000000" => leds_active <= "01110111";
                when "00100000" => leds_active <= "10101111";
                when "00010000" => leds_active <= "10101110";
                when "00001000" => leds_active <= "11011110";
                when "00000100" => leds_active <= "11111110";
                when "00000010" => leds_active <= "11110110";
                when "00000001" => leds_active <= "11111001";
                when others     => leds_active <= "11111111";
            end case;

	    end if;
	end process leds_activate;

	-- nastavení aktualnich LED
	LED <= leds_active;






end main;




-- ISID: 75579
