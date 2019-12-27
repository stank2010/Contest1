----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
-- Filename     UserWrDdr.vhd
-- Title        Top
--
-- Company      Design Gateway Co., Ltd.
-- Project      DDCamp
-- PJ No.       
-- Syntax       VHDL
-- Note         

-- Version      1.00
-- Author       B.Attapon
-- Date         2017/12/20
-- Remark       New Creation
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

Entity UserWrDdr Is
	Port
	(
		RstB			: in	std_logic;							-- use push button Key0 (active low)
		Clk				: in	std_logic;							-- clock input 100 MHz

		-- WrCtrl I/F
		MemInitDone		: in	std_logic;
		MtDdrWrReq		: out	std_logic;
		MtDdrWrBusy		: in	std_logic;
		MtDdrWrAddr		: out	std_logic_vector( 28 downto 7 );
		
		-- T2UWrFf I/F
		T2UWrFfRdEn		: out	std_logic;
		T2UWrFfRdData	: in	std_logic_vector( 63 downto 0 );
		T2UWrFfRdCnt	: in	std_logic_vector( 15 downto 0 );
		
		-- UWr2DFf I/F
		UWr2DFfRdEn		: in	std_logic;
		UWr2DFfRdData	: out	std_logic_vector( 63 downto 0 );
		UWr2DFfRdCnt	: out	std_logic_vector( 15 downto 0 )
	);
End Entity UserWrDdr;

Architecture rtl Of UserWrDdr Is

----------------------------------------------------------------------------------
-- Component declaration
----------------------------------------------------------------------------------
	
	
----------------------------------------------------------------------------------
-- Signal declaration
----------------------------------------------------------------------------------
	
	signal	rMemInitDone	: std_logic_vector( 1 downto 0 );
	signal 	rMtDdrWrReq		: std_logic;
	signal 	rMtDdrWrBusy	: std_logic_vector( 1 downto 0 );
	signal 	rMtDdrWrAddr	: std_logic_vector( 28 downto 7 );
	signal 	rDataCnt		: std_logic_vector( 3 downto 0 ); 	
Begin

----------------------------------------------------------------------------------
-- Output assignment
----------------------------------------------------------------------------------
	MtDdrWrReq	<= rMtDdrWrReq;
	MtDdrWrAddr	<= rMtDdrWrAddr;
	
----------------------------------------------------------------------------------
-- DFF 
----------------------------------------------------------------------------------
	
	u_rMemInitDone : Process (Clk) Is
	Begin
		if ( rising_edge(Clk) ) then
			if ( RstB='0' ) then
				rMemInitDone	<= "00";
			else
				-- Use rMemInitDone(1) in your design
				rMemInitDone	<= rMemInitDone(0) & MemInitDone;
			end if;
		end if;
	End Process u_rMemInitDone;
	
	u_rMtDdrWrBusy	: Process (Clk) Is
	Begin
		if( rising_edge(Clk) ) then
			if( RstB='0') then
				rMtDdrWrBusy	<= '0' & MtDdrWrBusy;
			else 
				rMtDdrWrBusy	<= rMtDdrWrBusy(0) & MtDdrWrBusy;
			end if;
		end if;
	End Process u_rMtDdrWrBusy;
	
	u_rMtDdrWrAddr	: Process (Clk) Is
	Begin
		if( rising_edge(Clk) ) then
			if( RstB='0' ) then
				rMtDdrWrAddr( 28 downto 7) <= (others=>'0');
			else 
				if( rMtDdrWrBusy(1)='1' and rMtDdrWrBusy(0)='0' and rDataCnt/="0100") then
					rMtDdrWrAddr( 28 downto 27 )	<= rMtDdrWrAddr( 28 downto 27 )+1;
				else 
					rMtDdrWrAddr( 28 downto 27 )	<= rMtDdrWrAddr( 28 downto 27 );
				end if;
			end if;
		end if;
	End Process u_rMtDdrWrAddr;
	
	u_rMtDdrWrReq 	: Process (Clk) Is
	Begin
		if( rising_edge(Clk) ) then
			if(RstB='0')then
				rMtDdrWrReq	<= '1';
			else 
				if(rMtDdrWrBusy(0)='1') then
					rMtDdrWrReq <= '0';
				elsif( rMtDdrWrBusy(1)='1' and rMtDdrWrBusy(0)='0' and rDataCnt/="0100") then
					rMtDdrWrReq	<= '1';
				else 
					rMtDdrWrReq <= rMtDdrWrReq;
				end if;
			end if;
		end if;
	End Process u_rMtDdrWrReq;
	
	u_rDataCnt	: Process (Clk) Is
	Begin
		if( rising_edge(Clk) ) then
			if( RstB='0' ) then
				rDataCnt	<="0000";
			else 
				if( rMtDdrWrBusy(1)='1' and rMtDdrWrBusy(0)='0' and rDataCnt/="0100")then
					rDataCnt	<= rDataCnt+1;
				else 
					rDataCnt 	<= rDataCnt;
				end if;
			end if;
		end if;
	End Process u_rDataCnt;
	
End Architecture rtl;