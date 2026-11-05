-- |-----------------------------------------------------------------------|
-- 
--              Synchronous Dual Port SRAM Compiler 
-- 
--                    UMC 0.18um Generic Logic Process 
--    __________________________________________________________________________
-- 
-- 
--        (C) Copyright 2002-2009 Faraday Technology Corp. All Rights Reserved.
-- 
--      This source code is an unpublished work belongs to Faraday Technology
--      Corp.  It is considered a trade secret and is not to be divulged or
--      used by parties who have not received written authorization from
--      Faraday Technology Corp.
-- 
--      Faraday's home page can be found at:
--      http://www.faraday-tech.com/
--     
-- ________________________________________________________________________________
-- 
--       Module Name       :  W1024_B8_BM2  
--       Word              :  1024          
--       Bit               :  8             
--       Byte              :  1             
--       Mux               :  2             
--       Power Ring Type   :  port          
--       Power Ring Width  :  2 (um)        
--       Output Loading    :  0.05 (pf)     
--       Input Data Slew   :  0.02 (ns)     
--       Input Clock Slew  :  0.02 (ns)     
-- 
-- ________________________________________________________________________________
-- 
--       Library          : FSA0M_A
--       Memaker          : 200901.2.1
--       Date             : 2024/10/07 09:38:07
-- 
-- ________________________________________________________________________________
-- 
--
-- Warning : 
--   If customer's design viloate the set-up time or hold time criteria of 
--   synchronous SRAM, it's possible to hit the meta-stable point of 
--   latch circuit in the decoder and cause the data loss in the memory 
--   bitcell. So please follow the memory IP's spec to design your 
--   product.
--
-- |-----------------------------------------------------------------------|
--
--       Library          : FSA0M_A
--       Memaker          : 200901.2.1
--       Date             : 2024/10/07 09:38:08
--
-- |-----------------------------------------------------------------------|

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.VITAL_Primitives.all;
use IEEE.VITAL_Timing.all;
use std.textio.all;
use IEEE.std_logic_textio.all;

-- entity declaration --
entity W1024_B8_BM2 is
   generic(
      SYN_CS:      integer  := 1;
      NO_SER_TOH:  integer  := 1;
      AddressSize: integer  := 10;
      Bits:        integer  := 8;
      Words:       integer  := 1024;
      Bytes:       integer  := 1;
      AspectRatio: integer  := 2;
      Tr2w:        time     := 2.231 ns;
      Tw2r:        time     := 1.780 ns;
      TOH:         time     := 0.744 ns;

      TimingChecksOn: Boolean := True;
      InstancePath: STRING := "*";
      Xon: Boolean := True;
      MsgOn: Boolean := True;


      tpd_CKA_DOA0_posedge : VitalDelayType01 :=  (1.564 ns, 1.564 ns);
      tpd_CKA_DOA1_posedge : VitalDelayType01 :=  (1.564 ns, 1.564 ns);
      tpd_CKA_DOA2_posedge : VitalDelayType01 :=  (1.564 ns, 1.564 ns);
      tpd_CKA_DOA3_posedge : VitalDelayType01 :=  (1.564 ns, 1.564 ns);
      tpd_CKA_DOA4_posedge : VitalDelayType01 :=  (1.564 ns, 1.564 ns);
      tpd_CKA_DOA5_posedge : VitalDelayType01 :=  (1.564 ns, 1.564 ns);
      tpd_CKA_DOA6_posedge : VitalDelayType01 :=  (1.564 ns, 1.564 ns);
      tpd_CKA_DOA7_posedge : VitalDelayType01 :=  (1.564 ns, 1.564 ns);

      tpd_CKB_DOB0_posedge : VitalDelayType01 :=  (1.564 ns, 1.564 ns);
      tpd_CKB_DOB1_posedge : VitalDelayType01 :=  (1.564 ns, 1.564 ns);
      tpd_CKB_DOB2_posedge : VitalDelayType01 :=  (1.564 ns, 1.564 ns);
      tpd_CKB_DOB3_posedge : VitalDelayType01 :=  (1.564 ns, 1.564 ns);
      tpd_CKB_DOB4_posedge : VitalDelayType01 :=  (1.564 ns, 1.564 ns);
      tpd_CKB_DOB5_posedge : VitalDelayType01 :=  (1.564 ns, 1.564 ns);
      tpd_CKB_DOB6_posedge : VitalDelayType01 :=  (1.564 ns, 1.564 ns);
      tpd_CKB_DOB7_posedge : VitalDelayType01 :=  (1.564 ns, 1.564 ns);

      tpd_OEA_DOA0    : VitalDelayType01Z := (0.869 ns, 0.869 ns, 0.552 ns, 0.869 ns, 0.552 ns, 0.869 ns);
      tpd_OEA_DOA1    : VitalDelayType01Z := (0.869 ns, 0.869 ns, 0.552 ns, 0.869 ns, 0.552 ns, 0.869 ns);
      tpd_OEA_DOA2    : VitalDelayType01Z := (0.869 ns, 0.869 ns, 0.552 ns, 0.869 ns, 0.552 ns, 0.869 ns);
      tpd_OEA_DOA3    : VitalDelayType01Z := (0.869 ns, 0.869 ns, 0.552 ns, 0.869 ns, 0.552 ns, 0.869 ns);
      tpd_OEA_DOA4    : VitalDelayType01Z := (0.869 ns, 0.869 ns, 0.552 ns, 0.869 ns, 0.552 ns, 0.869 ns);
      tpd_OEA_DOA5    : VitalDelayType01Z := (0.869 ns, 0.869 ns, 0.552 ns, 0.869 ns, 0.552 ns, 0.869 ns);
      tpd_OEA_DOA6    : VitalDelayType01Z := (0.869 ns, 0.869 ns, 0.552 ns, 0.869 ns, 0.552 ns, 0.869 ns);
      tpd_OEA_DOA7    : VitalDelayType01Z := (0.869 ns, 0.869 ns, 0.552 ns, 0.869 ns, 0.552 ns, 0.869 ns);
      tpd_OEB_DOB0    : VitalDelayType01Z := (0.869 ns, 0.869 ns, 0.552 ns, 0.869 ns, 0.552 ns, 0.869 ns);
      tpd_OEB_DOB1    : VitalDelayType01Z := (0.869 ns, 0.869 ns, 0.552 ns, 0.869 ns, 0.552 ns, 0.869 ns);
      tpd_OEB_DOB2    : VitalDelayType01Z := (0.869 ns, 0.869 ns, 0.552 ns, 0.869 ns, 0.552 ns, 0.869 ns);
      tpd_OEB_DOB3    : VitalDelayType01Z := (0.869 ns, 0.869 ns, 0.552 ns, 0.869 ns, 0.552 ns, 0.869 ns);
      tpd_OEB_DOB4    : VitalDelayType01Z := (0.869 ns, 0.869 ns, 0.552 ns, 0.869 ns, 0.552 ns, 0.869 ns);
      tpd_OEB_DOB5    : VitalDelayType01Z := (0.869 ns, 0.869 ns, 0.552 ns, 0.869 ns, 0.552 ns, 0.869 ns);
      tpd_OEB_DOB6    : VitalDelayType01Z := (0.869 ns, 0.869 ns, 0.552 ns, 0.869 ns, 0.552 ns, 0.869 ns);
      tpd_OEB_DOB7    : VitalDelayType01Z := (0.869 ns, 0.869 ns, 0.552 ns, 0.869 ns, 0.552 ns, 0.869 ns);

      tsetup_A0_CKA_posedge_posedge    :  VitalDelayType := 0.688 ns;
      tsetup_A0_CKA_negedge_posedge    :  VitalDelayType := 0.688 ns;
      tsetup_A1_CKA_posedge_posedge    :  VitalDelayType := 0.688 ns;
      tsetup_A1_CKA_negedge_posedge    :  VitalDelayType := 0.688 ns;
      tsetup_A2_CKA_posedge_posedge    :  VitalDelayType := 0.688 ns;
      tsetup_A2_CKA_negedge_posedge    :  VitalDelayType := 0.688 ns;
      tsetup_A3_CKA_posedge_posedge    :  VitalDelayType := 0.688 ns;
      tsetup_A3_CKA_negedge_posedge    :  VitalDelayType := 0.688 ns;
      tsetup_A4_CKA_posedge_posedge    :  VitalDelayType := 0.688 ns;
      tsetup_A4_CKA_negedge_posedge    :  VitalDelayType := 0.688 ns;
      tsetup_A5_CKA_posedge_posedge    :  VitalDelayType := 0.688 ns;
      tsetup_A5_CKA_negedge_posedge    :  VitalDelayType := 0.688 ns;
      tsetup_A6_CKA_posedge_posedge    :  VitalDelayType := 0.688 ns;
      tsetup_A6_CKA_negedge_posedge    :  VitalDelayType := 0.688 ns;
      tsetup_A7_CKA_posedge_posedge    :  VitalDelayType := 0.688 ns;
      tsetup_A7_CKA_negedge_posedge    :  VitalDelayType := 0.688 ns;
      tsetup_A8_CKA_posedge_posedge    :  VitalDelayType := 0.688 ns;
      tsetup_A8_CKA_negedge_posedge    :  VitalDelayType := 0.688 ns;
      tsetup_A9_CKA_posedge_posedge    :  VitalDelayType := 0.688 ns;
      tsetup_A9_CKA_negedge_posedge    :  VitalDelayType := 0.688 ns;
      tsetup_B0_CKB_posedge_posedge    :  VitalDelayType := 0.688 ns;
      tsetup_B0_CKB_negedge_posedge    :  VitalDelayType := 0.688 ns;
      tsetup_B1_CKB_posedge_posedge    :  VitalDelayType := 0.688 ns;
      tsetup_B1_CKB_negedge_posedge    :  VitalDelayType := 0.688 ns;
      tsetup_B2_CKB_posedge_posedge    :  VitalDelayType := 0.688 ns;
      tsetup_B2_CKB_negedge_posedge    :  VitalDelayType := 0.688 ns;
      tsetup_B3_CKB_posedge_posedge    :  VitalDelayType := 0.688 ns;
      tsetup_B3_CKB_negedge_posedge    :  VitalDelayType := 0.688 ns;
      tsetup_B4_CKB_posedge_posedge    :  VitalDelayType := 0.688 ns;
      tsetup_B4_CKB_negedge_posedge    :  VitalDelayType := 0.688 ns;
      tsetup_B5_CKB_posedge_posedge    :  VitalDelayType := 0.688 ns;
      tsetup_B5_CKB_negedge_posedge    :  VitalDelayType := 0.688 ns;
      tsetup_B6_CKB_posedge_posedge    :  VitalDelayType := 0.688 ns;
      tsetup_B6_CKB_negedge_posedge    :  VitalDelayType := 0.688 ns;
      tsetup_B7_CKB_posedge_posedge    :  VitalDelayType := 0.688 ns;
      tsetup_B7_CKB_negedge_posedge    :  VitalDelayType := 0.688 ns;
      tsetup_B8_CKB_posedge_posedge    :  VitalDelayType := 0.688 ns;
      tsetup_B8_CKB_negedge_posedge    :  VitalDelayType := 0.688 ns;
      tsetup_B9_CKB_posedge_posedge    :  VitalDelayType := 0.688 ns;
      tsetup_B9_CKB_negedge_posedge    :  VitalDelayType := 0.688 ns;
      thold_A0_CKA_posedge_posedge     :  VitalDelayType := 0.122 ns;
      thold_A0_CKA_negedge_posedge     :  VitalDelayType := 0.122 ns;
      thold_A1_CKA_posedge_posedge     :  VitalDelayType := 0.122 ns;
      thold_A1_CKA_negedge_posedge     :  VitalDelayType := 0.122 ns;
      thold_A2_CKA_posedge_posedge     :  VitalDelayType := 0.122 ns;
      thold_A2_CKA_negedge_posedge     :  VitalDelayType := 0.122 ns;
      thold_A3_CKA_posedge_posedge     :  VitalDelayType := 0.122 ns;
      thold_A3_CKA_negedge_posedge     :  VitalDelayType := 0.122 ns;
      thold_A4_CKA_posedge_posedge     :  VitalDelayType := 0.122 ns;
      thold_A4_CKA_negedge_posedge     :  VitalDelayType := 0.122 ns;
      thold_A5_CKA_posedge_posedge     :  VitalDelayType := 0.122 ns;
      thold_A5_CKA_negedge_posedge     :  VitalDelayType := 0.122 ns;
      thold_A6_CKA_posedge_posedge     :  VitalDelayType := 0.122 ns;
      thold_A6_CKA_negedge_posedge     :  VitalDelayType := 0.122 ns;
      thold_A7_CKA_posedge_posedge     :  VitalDelayType := 0.122 ns;
      thold_A7_CKA_negedge_posedge     :  VitalDelayType := 0.122 ns;
      thold_A8_CKA_posedge_posedge     :  VitalDelayType := 0.122 ns;
      thold_A8_CKA_negedge_posedge     :  VitalDelayType := 0.122 ns;
      thold_A9_CKA_posedge_posedge     :  VitalDelayType := 0.122 ns;
      thold_A9_CKA_negedge_posedge     :  VitalDelayType := 0.122 ns;
      thold_B0_CKB_posedge_posedge     :  VitalDelayType := 0.122 ns;
      thold_B0_CKB_negedge_posedge     :  VitalDelayType := 0.122 ns;
      thold_B1_CKB_posedge_posedge     :  VitalDelayType := 0.122 ns;
      thold_B1_CKB_negedge_posedge     :  VitalDelayType := 0.122 ns;
      thold_B2_CKB_posedge_posedge     :  VitalDelayType := 0.122 ns;
      thold_B2_CKB_negedge_posedge     :  VitalDelayType := 0.122 ns;
      thold_B3_CKB_posedge_posedge     :  VitalDelayType := 0.122 ns;
      thold_B3_CKB_negedge_posedge     :  VitalDelayType := 0.122 ns;
      thold_B4_CKB_posedge_posedge     :  VitalDelayType := 0.122 ns;
      thold_B4_CKB_negedge_posedge     :  VitalDelayType := 0.122 ns;
      thold_B5_CKB_posedge_posedge     :  VitalDelayType := 0.122 ns;
      thold_B5_CKB_negedge_posedge     :  VitalDelayType := 0.122 ns;
      thold_B6_CKB_posedge_posedge     :  VitalDelayType := 0.122 ns;
      thold_B6_CKB_negedge_posedge     :  VitalDelayType := 0.122 ns;
      thold_B7_CKB_posedge_posedge     :  VitalDelayType := 0.122 ns;
      thold_B7_CKB_negedge_posedge     :  VitalDelayType := 0.122 ns;
      thold_B8_CKB_posedge_posedge     :  VitalDelayType := 0.122 ns;
      thold_B8_CKB_negedge_posedge     :  VitalDelayType := 0.122 ns;
      thold_B9_CKB_posedge_posedge     :  VitalDelayType := 0.122 ns;
      thold_B9_CKB_negedge_posedge     :  VitalDelayType := 0.122 ns;
      tsetup_DIA0_CKA_posedge_posedge    :  VitalDelayType := 0.264 ns;
      tsetup_DIA0_CKA_negedge_posedge    :  VitalDelayType := 0.264 ns;
      tsetup_DIA1_CKA_posedge_posedge    :  VitalDelayType := 0.264 ns;
      tsetup_DIA1_CKA_negedge_posedge    :  VitalDelayType := 0.264 ns;
      tsetup_DIA2_CKA_posedge_posedge    :  VitalDelayType := 0.264 ns;
      tsetup_DIA2_CKA_negedge_posedge    :  VitalDelayType := 0.264 ns;
      tsetup_DIA3_CKA_posedge_posedge    :  VitalDelayType := 0.264 ns;
      tsetup_DIA3_CKA_negedge_posedge    :  VitalDelayType := 0.264 ns;
      tsetup_DIA4_CKA_posedge_posedge    :  VitalDelayType := 0.264 ns;
      tsetup_DIA4_CKA_negedge_posedge    :  VitalDelayType := 0.264 ns;
      tsetup_DIA5_CKA_posedge_posedge    :  VitalDelayType := 0.264 ns;
      tsetup_DIA5_CKA_negedge_posedge    :  VitalDelayType := 0.264 ns;
      tsetup_DIA6_CKA_posedge_posedge    :  VitalDelayType := 0.264 ns;
      tsetup_DIA6_CKA_negedge_posedge    :  VitalDelayType := 0.264 ns;
      tsetup_DIA7_CKA_posedge_posedge    :  VitalDelayType := 0.264 ns;
      tsetup_DIA7_CKA_negedge_posedge    :  VitalDelayType := 0.264 ns;
      tsetup_DIB0_CKB_posedge_posedge    :  VitalDelayType := 0.264 ns;
      tsetup_DIB0_CKB_negedge_posedge    :  VitalDelayType := 0.264 ns;
      tsetup_DIB1_CKB_posedge_posedge    :  VitalDelayType := 0.264 ns;
      tsetup_DIB1_CKB_negedge_posedge    :  VitalDelayType := 0.264 ns;
      tsetup_DIB2_CKB_posedge_posedge    :  VitalDelayType := 0.264 ns;
      tsetup_DIB2_CKB_negedge_posedge    :  VitalDelayType := 0.264 ns;
      tsetup_DIB3_CKB_posedge_posedge    :  VitalDelayType := 0.264 ns;
      tsetup_DIB3_CKB_negedge_posedge    :  VitalDelayType := 0.264 ns;
      tsetup_DIB4_CKB_posedge_posedge    :  VitalDelayType := 0.264 ns;
      tsetup_DIB4_CKB_negedge_posedge    :  VitalDelayType := 0.264 ns;
      tsetup_DIB5_CKB_posedge_posedge    :  VitalDelayType := 0.264 ns;
      tsetup_DIB5_CKB_negedge_posedge    :  VitalDelayType := 0.264 ns;
      tsetup_DIB6_CKB_posedge_posedge    :  VitalDelayType := 0.264 ns;
      tsetup_DIB6_CKB_negedge_posedge    :  VitalDelayType := 0.264 ns;
      tsetup_DIB7_CKB_posedge_posedge    :  VitalDelayType := 0.264 ns;
      tsetup_DIB7_CKB_negedge_posedge    :  VitalDelayType := 0.264 ns;
      thold_DIA0_CKA_posedge_posedge     :  VitalDelayType := 0.000 ns;
      thold_DIA0_CKA_negedge_posedge     :  VitalDelayType := 0.000 ns;
      thold_DIA1_CKA_posedge_posedge     :  VitalDelayType := 0.000 ns;
      thold_DIA1_CKA_negedge_posedge     :  VitalDelayType := 0.000 ns;
      thold_DIA2_CKA_posedge_posedge     :  VitalDelayType := 0.000 ns;
      thold_DIA2_CKA_negedge_posedge     :  VitalDelayType := 0.000 ns;
      thold_DIA3_CKA_posedge_posedge     :  VitalDelayType := 0.000 ns;
      thold_DIA3_CKA_negedge_posedge     :  VitalDelayType := 0.000 ns;
      thold_DIA4_CKA_posedge_posedge     :  VitalDelayType := 0.000 ns;
      thold_DIA4_CKA_negedge_posedge     :  VitalDelayType := 0.000 ns;
      thold_DIA5_CKA_posedge_posedge     :  VitalDelayType := 0.000 ns;
      thold_DIA5_CKA_negedge_posedge     :  VitalDelayType := 0.000 ns;
      thold_DIA6_CKA_posedge_posedge     :  VitalDelayType := 0.000 ns;
      thold_DIA6_CKA_negedge_posedge     :  VitalDelayType := 0.000 ns;
      thold_DIA7_CKA_posedge_posedge     :  VitalDelayType := 0.000 ns;
      thold_DIA7_CKA_negedge_posedge     :  VitalDelayType := 0.000 ns;
      thold_DIB0_CKB_posedge_posedge     :  VitalDelayType := 0.000 ns;
      thold_DIB0_CKB_negedge_posedge     :  VitalDelayType := 0.000 ns;
      thold_DIB1_CKB_posedge_posedge     :  VitalDelayType := 0.000 ns;
      thold_DIB1_CKB_negedge_posedge     :  VitalDelayType := 0.000 ns;
      thold_DIB2_CKB_posedge_posedge     :  VitalDelayType := 0.000 ns;
      thold_DIB2_CKB_negedge_posedge     :  VitalDelayType := 0.000 ns;
      thold_DIB3_CKB_posedge_posedge     :  VitalDelayType := 0.000 ns;
      thold_DIB3_CKB_negedge_posedge     :  VitalDelayType := 0.000 ns;
      thold_DIB4_CKB_posedge_posedge     :  VitalDelayType := 0.000 ns;
      thold_DIB4_CKB_negedge_posedge     :  VitalDelayType := 0.000 ns;
      thold_DIB5_CKB_posedge_posedge     :  VitalDelayType := 0.000 ns;
      thold_DIB5_CKB_negedge_posedge     :  VitalDelayType := 0.000 ns;
      thold_DIB6_CKB_posedge_posedge     :  VitalDelayType := 0.000 ns;
      thold_DIB6_CKB_negedge_posedge     :  VitalDelayType := 0.000 ns;
      thold_DIB7_CKB_posedge_posedge     :  VitalDelayType := 0.000 ns;
      thold_DIB7_CKB_negedge_posedge     :  VitalDelayType := 0.000 ns;
      tsetup_WEAN_CKA_posedge_posedge   :  VitalDelayType := 0.374 ns;
      tsetup_WEAN_CKA_negedge_posedge   :  VitalDelayType := 0.374 ns;
      thold_WEAN_CKA_posedge_posedge    :  VitalDelayType := 0.069 ns;
      thold_WEAN_CKA_negedge_posedge    :  VitalDelayType := 0.069 ns;
      tsetup_WEBN_CKB_posedge_posedge   :  VitalDelayType := 0.374 ns;
      tsetup_WEBN_CKB_negedge_posedge   :  VitalDelayType := 0.374 ns;
      thold_WEBN_CKB_posedge_posedge    :  VitalDelayType := 0.069 ns;
      thold_WEBN_CKB_negedge_posedge    :  VitalDelayType := 0.069 ns;
      tsetup_CSA_CKA_posedge_posedge    :  VitalDelayType := 0.793 ns;
      tsetup_CSA_CKA_negedge_posedge    :  VitalDelayType := 0.793 ns;
      tsetup_CSB_CKB_posedge_posedge    :  VitalDelayType := 0.793 ns;
      tsetup_CSB_CKB_negedge_posedge    :  VitalDelayType := 0.793 ns;
      thold_CSA_CKA_posedge_posedge     :  VitalDelayType := 0.000 ns;
      thold_CSA_CKA_negedge_posedge     :  VitalDelayType := 0.000 ns;
      thold_CSB_CKB_posedge_posedge     :  VitalDelayType := 0.000 ns;
      thold_CSB_CKB_negedge_posedge     :  VitalDelayType := 0.000 ns;
      tperiod_CKA                       :  VitalDelayType := 2.231 ns;
      tperiod_CKB                       :  VitalDelayType := 2.231 ns;
      tpw_CKA_posedge                   :  VitalDelayType := 0.744 ns;
      tpw_CKB_posedge                   :  VitalDelayType := 0.744 ns;
      tpw_CKA_negedge                   :  VitalDelayType := 0.744 ns;
      tpw_CKB_negedge                   :  VitalDelayType := 0.744 ns;
      tipd_A0                     :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_A1                     :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_A2                     :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_A3                     :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_A4                     :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_A5                     :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_A6                     :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_A7                     :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_A8                     :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_A9                     :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_B0                     :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_B1                     :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_B2                     :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_B3                     :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_B4                     :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_B5                     :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_B6                     :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_B7                     :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_B8                     :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_B9                     :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIA0                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIA1                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIA2                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIA3                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIA4                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIA5                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIA6                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIA7                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIB0                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIB1                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIB2                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIB3                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIB4                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIB5                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIB6                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIB7                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_WEAN                       :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_WEBN                       :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_CSA                        :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_CSB                        :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_CKA                        :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_CKB                        :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_OEA                        :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_OEB                        :  VitalDelayType01 := (0.000 ns, 0.000 ns)
      );

   port(
      A0                            :   IN   std_logic;
      A1                            :   IN   std_logic;
      A2                            :   IN   std_logic;
      A3                            :   IN   std_logic;
      A4                            :   IN   std_logic;
      A5                            :   IN   std_logic;
      A6                            :   IN   std_logic;
      A7                            :   IN   std_logic;
      A8                            :   IN   std_logic;
      A9                            :   IN   std_logic;
      B0                            :   IN   std_logic;
      B1                            :   IN   std_logic;
      B2                            :   IN   std_logic;
      B3                            :   IN   std_logic;
      B4                            :   IN   std_logic;
      B5                            :   IN   std_logic;
      B6                            :   IN   std_logic;
      B7                            :   IN   std_logic;
      B8                            :   IN   std_logic;
      B9                            :   IN   std_logic;
      DOA0                        :   OUT   std_logic;
      DOA1                        :   OUT   std_logic;
      DOA2                        :   OUT   std_logic;
      DOA3                        :   OUT   std_logic;
      DOA4                        :   OUT   std_logic;
      DOA5                        :   OUT   std_logic;
      DOA6                        :   OUT   std_logic;
      DOA7                        :   OUT   std_logic;
      DOB0                        :   OUT   std_logic;
      DOB1                        :   OUT   std_logic;
      DOB2                        :   OUT   std_logic;
      DOB3                        :   OUT   std_logic;
      DOB4                        :   OUT   std_logic;
      DOB5                        :   OUT   std_logic;
      DOB6                        :   OUT   std_logic;
      DOB7                        :   OUT   std_logic;
      DIA0                        :   IN   std_logic;
      DIA1                        :   IN   std_logic;
      DIA2                        :   IN   std_logic;
      DIA3                        :   IN   std_logic;
      DIA4                        :   IN   std_logic;
      DIA5                        :   IN   std_logic;
      DIA6                        :   IN   std_logic;
      DIA7                        :   IN   std_logic;
      DIB0                        :   IN   std_logic;
      DIB1                        :   IN   std_logic;
      DIB2                        :   IN   std_logic;
      DIB3                        :   IN   std_logic;
      DIB4                        :   IN   std_logic;
      DIB5                        :   IN   std_logic;
      DIB6                        :   IN   std_logic;
      DIB7                        :   IN   std_logic;
      WEAN                           :   IN   std_logic;
      WEBN                           :   IN   std_logic;
      CKA                            :   IN   std_logic;
      CKB                            :   IN   std_logic;
      CSA                            :   IN   std_logic;
      CSB                            :   IN   std_logic;
      OEA                            :   IN   std_logic;
      OEB                            :   IN   std_logic
      );

attribute VITAL_LEVEL0 of W1024_B8_BM2 : entity is TRUE;

end W1024_B8_BM2;

-- architecture body --
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.VITAL_Primitives.all;
use IEEE.VITAL_Timing.all;

architecture behavior of W1024_B8_BM2 is
   -- attribute VITALMEMORY_LEVEL1 of behavior : architecture is TRUE;

   CONSTANT True_flg:       integer := 0;
   CONSTANT False_flg:      integer := 1;
   CONSTANT Range_flg:      integer := 2;

   FUNCTION Minimum ( CONSTANT t1, t2 : IN TIME ) RETURN TIME IS
   BEGIN
      IF (t1 < t2) THEN RETURN (t1); ELSE RETURN (t2); END IF;
   END Minimum;

   FUNCTION Maximum ( CONSTANT t1, t2 : IN TIME ) RETURN TIME IS
   BEGIN
      IF (t1 < t2) THEN RETURN (t2); ELSE RETURN (t1); END IF;
   END Maximum;

   FUNCTION BVtoI(bin: std_logic_vector) RETURN integer IS
      variable result: integer;
   BEGIN
      result := 0;
      for i in bin'range loop
         if bin(i) = '1' then
            result := result + 2**i;
         end if;
      end loop;
      return result;
   END; -- BVtoI

   PROCEDURE ScheduleOutputDelay (
       SIGNAL   OutSignal        : OUT std_logic;
       VARIABLE Data             : IN  std_logic;
       CONSTANT Delay            : IN  VitalDelayType01 := VitalDefDelay01;
       VARIABLE Previous_A       : IN  std_logic_vector(AddressSize-1 downto 0);
       VARIABLE Current_A        : IN  std_logic_vector(AddressSize-1 downto 0);
       CONSTANT NO_SER_TOH       : IN  integer
   ) IS
   BEGIN

      if (NO_SER_TOH /= 1) then
         OutSignal <= TRANSPORT 'X' AFTER TOH;
         OutSignal <= TRANSPORT Data AFTER Maximum(Delay(tr10), Delay(tr01));
      else
         if (Current_A /= Previous_A) then
            OutSignal <= TRANSPORT 'X' AFTER TOH;
            OutSignal <= TRANSPORT Data AFTER Maximum(Delay(tr10), Delay(tr01));
         else
            OutSignal <= TRANSPORT Data AFTER Maximum(Delay(tr10), Delay(tr01));
         end if;
      end if;
   END ScheduleOutputDelay;

   FUNCTION TO_INTEGER (
     a: std_logic_vector
   ) RETURN INTEGER IS
     VARIABLE y: INTEGER := 0;
   BEGIN
        y := 0;
        FOR i IN a'RANGE LOOP
            y := y * 2;
            IF a(i) /= '1' AND a(i) /= '0' THEN
                y := 0;
                EXIT;
            ELSIF a(i) = '1' THEN
                y := y + 1;
            END IF;
        END LOOP;
        RETURN y;
   END TO_INTEGER;

   function AddressRangeCheck(AddressItem: std_logic_vector; flag_Address: integer) return integer is
     variable Uresult : std_logic;
     variable status  : integer := 0;

   begin
      if (Bits /= 1) then
         Uresult := AddressItem(0) xor AddressItem(1);
         for i in 2 to AddressItem'length-1 loop
            Uresult := Uresult xor AddressItem(i);
         end loop;
      else
         Uresult := AddressItem(0);
      end if;

      if (Uresult = 'U') then
         status := False_flg;
      elsif (Uresult = 'X') then
         status := False_flg;
      elsif (Uresult = 'Z') then
         status := False_flg;
      else
         status := True_flg;
      end if;

      if (status=False_flg) then
        if (flag_Address = True_flg) then
           -- Generate Error Messae --
           assert FALSE report "** MEM_Error: Unknown value occurred in Address." severity WARNING;
        end if;
      end if;

      if (status=True_flg) then
         if ((BVtoI(AddressItem)) >= Words) then
             assert FALSE report "** MEM_Error: Out of range occurred in Address." severity WARNING;
             status := Range_flg;
         else
             status := True_flg;
         end if;
      end if;

      return status;
   end AddressRangeCheck;

   function CS_monitor(CSItem: std_logic; flag_CS: integer) return integer is
     variable status  : integer := 0;

   begin
      if (CSItem = 'U') then
         status := False_flg;
      elsif (CSItem = 'X') then
         status := False_flg;
      elsif (CSItem = 'Z') then
         status := False_flg;
      else
         status := True_flg;
      end if;

      if (status=False_flg) then
        if (flag_CS = True_flg) then
           -- Generate Error Messae --
           assert FALSE report "** MEM_Error: Unknown value occurred in ChipSelect." severity WARNING;
        end if;
      end if;

      return status;
   end CS_monitor;

   Type memoryArray Is array (Words-1 downto 0) Of std_logic_vector (Bits-1 downto 0);

   SIGNAL CSA_ipd        : std_logic := 'X';
   SIGNAL CSB_ipd        : std_logic := 'X';
   SIGNAL OEA_ipd        : std_logic := 'X';
   SIGNAL OEB_ipd        : std_logic := 'X';
   SIGNAL CKA_ipd        : std_logic := 'X';
   SIGNAL CKB_ipd        : std_logic := 'X';
   SIGNAL A_ipd          : std_logic_vector(AddressSize-1 downto 0) := (others => 'X');
   SIGNAL B_ipd          : std_logic_vector(AddressSize-1 downto 0) := (others => 'X');
   SIGNAL WEAN_ipd       : std_logic := 'X';
   SIGNAL WEBN_ipd       : std_logic := 'X';
   SIGNAL DIA_ipd        : std_logic_vector(Bits-1 downto 0) := (others => 'X');
   SIGNAL DIB_ipd        : std_logic_vector(Bits-1 downto 0) := (others => 'X');
   SIGNAL DOA_int        : std_logic_vector(Bits-1 downto 0) := (others => 'X');
   SIGNAL DOB_int        : std_logic_vector(Bits-1 downto 0) := (others => 'X');

begin

   ---------------------
   --  INPUT PATH DELAYs
   ---------------------
   WireDelay : block
   begin
   VitalWireDelay (CSA_ipd, CSA, tipd_CSA);
   VitalWireDelay (CSB_ipd, CSB, tipd_CSB);
   VitalWireDelay (WEAN_ipd, WEAN, tipd_WEAN);
   VitalWireDelay (WEBN_ipd, WEBN, tipd_WEBN);
   VitalWireDelay (OEA_ipd, OEA, tipd_OEA);
   VitalWireDelay (OEB_ipd, OEB, tipd_OEB);
   VitalWireDelay (CKA_ipd, CKA, tipd_CKA);
   VitalWireDelay (CKB_ipd, CKB, tipd_CKB);
   VitalWireDelay (A_ipd(0), A0, tipd_A0);
   VitalWireDelay (A_ipd(1), A1, tipd_A1);
   VitalWireDelay (A_ipd(2), A2, tipd_A2);
   VitalWireDelay (A_ipd(3), A3, tipd_A3);
   VitalWireDelay (A_ipd(4), A4, tipd_A4);
   VitalWireDelay (A_ipd(5), A5, tipd_A5);
   VitalWireDelay (A_ipd(6), A6, tipd_A6);
   VitalWireDelay (A_ipd(7), A7, tipd_A7);
   VitalWireDelay (A_ipd(8), A8, tipd_A8);
   VitalWireDelay (A_ipd(9), A9, tipd_A9);
   VitalWireDelay (B_ipd(0), B0, tipd_B0);
   VitalWireDelay (B_ipd(1), B1, tipd_B1);
   VitalWireDelay (B_ipd(2), B2, tipd_B2);
   VitalWireDelay (B_ipd(3), B3, tipd_B3);
   VitalWireDelay (B_ipd(4), B4, tipd_B4);
   VitalWireDelay (B_ipd(5), B5, tipd_B5);
   VitalWireDelay (B_ipd(6), B6, tipd_B6);
   VitalWireDelay (B_ipd(7), B7, tipd_B7);
   VitalWireDelay (B_ipd(8), B8, tipd_B8);
   VitalWireDelay (B_ipd(9), B9, tipd_B9);
   VitalWireDelay (DIA_ipd(0), DIA0, tipd_DIA0);
   VitalWireDelay (DIB_ipd(0), DIB0, tipd_DIB0);
   VitalWireDelay (DIA_ipd(1), DIA1, tipd_DIA1);
   VitalWireDelay (DIB_ipd(1), DIB1, tipd_DIB1);
   VitalWireDelay (DIA_ipd(2), DIA2, tipd_DIA2);
   VitalWireDelay (DIB_ipd(2), DIB2, tipd_DIB2);
   VitalWireDelay (DIA_ipd(3), DIA3, tipd_DIA3);
   VitalWireDelay (DIB_ipd(3), DIB3, tipd_DIB3);
   VitalWireDelay (DIA_ipd(4), DIA4, tipd_DIA4);
   VitalWireDelay (DIB_ipd(4), DIB4, tipd_DIB4);
   VitalWireDelay (DIA_ipd(5), DIA5, tipd_DIA5);
   VitalWireDelay (DIB_ipd(5), DIB5, tipd_DIB5);
   VitalWireDelay (DIA_ipd(6), DIA6, tipd_DIA6);
   VitalWireDelay (DIB_ipd(6), DIB6, tipd_DIB6);
   VitalWireDelay (DIA_ipd(7), DIA7, tipd_DIA7);
   VitalWireDelay (DIB_ipd(7), DIB7, tipd_DIB7);

   end block;

   VitalBUFIF1 (q      => DOA0,
                data   => DOA_int(0),
                enable => OEA_ipd,
                tpd_enable_q => tpd_OEA_DOA0);
   VitalBUFIF1 (q      => DOA1,
                data   => DOA_int(1),
                enable => OEA_ipd,
                tpd_enable_q => tpd_OEA_DOA1);
   VitalBUFIF1 (q      => DOA2,
                data   => DOA_int(2),
                enable => OEA_ipd,
                tpd_enable_q => tpd_OEA_DOA2);
   VitalBUFIF1 (q      => DOA3,
                data   => DOA_int(3),
                enable => OEA_ipd,
                tpd_enable_q => tpd_OEA_DOA3);
   VitalBUFIF1 (q      => DOA4,
                data   => DOA_int(4),
                enable => OEA_ipd,
                tpd_enable_q => tpd_OEA_DOA4);
   VitalBUFIF1 (q      => DOA5,
                data   => DOA_int(5),
                enable => OEA_ipd,
                tpd_enable_q => tpd_OEA_DOA5);
   VitalBUFIF1 (q      => DOA6,
                data   => DOA_int(6),
                enable => OEA_ipd,
                tpd_enable_q => tpd_OEA_DOA6);
   VitalBUFIF1 (q      => DOA7,
                data   => DOA_int(7),
                enable => OEA_ipd,
                tpd_enable_q => tpd_OEA_DOA7);

   VitalBUFIF1 (q      => DOB0,
                data   => DOB_int(0),
                enable => OEB_ipd,
                tpd_enable_q => tpd_OEB_DOB0);
   VitalBUFIF1 (q      => DOB1,
                data   => DOB_int(1),
                enable => OEB_ipd,
                tpd_enable_q => tpd_OEB_DOB1);
   VitalBUFIF1 (q      => DOB2,
                data   => DOB_int(2),
                enable => OEB_ipd,
                tpd_enable_q => tpd_OEB_DOB2);
   VitalBUFIF1 (q      => DOB3,
                data   => DOB_int(3),
                enable => OEB_ipd,
                tpd_enable_q => tpd_OEB_DOB3);
   VitalBUFIF1 (q      => DOB4,
                data   => DOB_int(4),
                enable => OEB_ipd,
                tpd_enable_q => tpd_OEB_DOB4);
   VitalBUFIF1 (q      => DOB5,
                data   => DOB_int(5),
                enable => OEB_ipd,
                tpd_enable_q => tpd_OEB_DOB5);
   VitalBUFIF1 (q      => DOB6,
                data   => DOB_int(6),
                enable => OEB_ipd,
                tpd_enable_q => tpd_OEB_DOB6);
   VitalBUFIF1 (q      => DOB7,
                data   => DOB_int(7),
                enable => OEB_ipd,
                tpd_enable_q => tpd_OEB_DOB7);

   --------------------
   --  BEHAVIOR SECTION
   --------------------
   VITALBehavior : PROCESS (CSA_ipd,
                            CSB_ipd,
                            OEA_ipd,
                            OEB_ipd,
                            A_ipd,
                            B_ipd,
                            WEAN_ipd,
                            WEBN_ipd,
                            DIA_ipd,
                            DIB_ipd,
                            CKA_ipd,
                            CKB_ipd)

   -- timing check results
   VARIABLE Tviol_A_CKA_posedge  : STD_ULOGIC := '0';
   VARIABLE Tviol_B_CKB_posedge  : STD_ULOGIC := '0';
   VARIABLE Tviol_WEAN_CKA_posedge  : STD_ULOGIC := '0';
   VARIABLE Tviol_WEBN_CKB_posedge  : STD_ULOGIC := '0';
   VARIABLE Tviol_DIA_CKA_posedge   : STD_ULOGIC := '0';
   VARIABLE Tviol_DIB_CKB_posedge   : STD_ULOGIC := '0';
   VARIABLE Tviol_CSA_CKA_posedge  : STD_ULOGIC := '0';
   VARIABLE Tviol_CSB_CKB_posedge  : STD_ULOGIC := '0';

   VARIABLE Pviol_CKA    : STD_ULOGIC := '0';
   VARIABLE Pviol_CKB    : STD_ULOGIC := '0';
   VARIABLE Pdata_CKA    : VitalPeriodDataType := VitalPeriodDataInit;
   VARIABLE Pdata_CKB    : VitalPeriodDataType := VitalPeriodDataInit;

   VARIABLE Tmkr_A_CKA_posedge   : VitalTimingDataType := VitalTimingDataInit;
   VARIABLE Tmkr_B_CKB_posedge   : VitalTimingDataType := VitalTimingDataInit;
   VARIABLE Tmkr_WEAN_CKA_posedge   : VitalTimingDataType := VitalTimingDataInit;
   VARIABLE Tmkr_WEBN_CKB_posedge   : VitalTimingDataType := VitalTimingDataInit;
   VARIABLE Tmkr_DIA_CKA_posedge   : VitalTimingDataType := VitalTimingDataInit;
   VARIABLE Tmkr_DIB_CKB_posedge   : VitalTimingDataType := VitalTimingDataInit;
   VARIABLE Tmkr_CSA_CKA_posedge   : VitalTimingDataType := VitalTimingDataInit;
   VARIABLE Tmkr_CSB_CKB_posedge   : VitalTimingDataType := VitalTimingDataInit;

   VARIABLE DOA_zd : std_logic_vector(Bits-1 downto 0) := (others => 'X');
   VARIABLE DOB_zd : std_logic_vector(Bits-1 downto 0) := (others => 'X');
   VARIABLE memoryCore  : memoryArray;

   VARIABLE cka_change   : std_logic_vector(1 downto 0);
   VARIABLE ckb_change   : std_logic_vector(1 downto 0);
   VARIABLE wea_csa      : std_logic_vector(1 downto 0);
   VARIABLE web_csb      : std_logic_vector(1 downto 0);

   -- previous latch data
   VARIABLE Latch_A        : std_logic_vector(AddressSize-1 downto 0) := (others => 'X');
   VARIABLE Latch_B        : std_logic_vector(AddressSize-1 downto 0) := (others => 'X');
   VARIABLE Latch_DIA       : std_logic_vector(Bits-1 downto 0) := (others => 'X');
   VARIABLE Latch_DIB       : std_logic_vector(Bits-1 downto 0) := (others => 'X');
   VARIABLE Latch_WEAN      : std_logic := 'X';
   VARIABLE Latch_WEBN      : std_logic := 'X';
   VARIABLE Latch_CSA       : std_logic := 'X';
   VARIABLE Latch_CSB       : std_logic := 'X';

   -- internal latch data
   VARIABLE A_i            : std_logic_vector(AddressSize-1 downto 0) := (others => 'X');
   VARIABLE B_i            : std_logic_vector(AddressSize-1 downto 0) := (others => 'X');
   VARIABLE DIA_i           : std_logic_vector(Bits-1 downto 0) := (others => 'X');
   VARIABLE DIB_i           : std_logic_vector(Bits-1 downto 0) := (others => 'X');
   VARIABLE WEAN_i          : std_logic := 'X';
   VARIABLE WEBN_i          : std_logic := 'X';
   VARIABLE CSA_i           : std_logic := 'X';
   VARIABLE CSB_i           : std_logic := 'X';

   VARIABLE Last_WEAN_i      : std_logic := 'X';
   VARIABLE Last_WEBN_i      : std_logic := 'X';

   VARIABLE last_A         : std_logic_vector(AddressSize-1 downto 0) := (others => 'X');
   VARIABLE last_B         : std_logic_vector(AddressSize-1 downto 0) := (others => 'X');

   VARIABLE LastClkAEdge    : std_logic := 'X';
   VARIABLE LastClkBEdge    : std_logic := 'X';

   VARIABLE flag_A: integer   := True_flg;
   VARIABLE flag_B: integer   := True_flg;
   VARIABLE flag_CSA: integer   := True_flg;
   VARIABLE flag_CSB: integer   := True_flg;

   VARIABLE LastCycleAAddress  : std_logic_vector(AddressSize-1 downto 0) := (others => 'X');
   VARIABLE LastCycleBAddress  : std_logic_vector(AddressSize-1 downto 0) := (others => 'X');
   VARIABLE Last_tc_ClkA_PosEdge     : time := 0 ns;
   VARIABLE Last_tc_ClkB_PosEdge     : time := 0 ns;

   begin

   ------------------------
   --  Timing Check Section
   ------------------------
   if (TimingChecksOn) then
         VitalSetupHoldCheck (
          Violation               => Tviol_A_CKA_posedge,
          TimingData              => Tmkr_A_CKA_posedge,
          TestSignal              => A_ipd,
          TestSignalName          => "A",
          TestDelay               => 0 ns,
          RefSignal               => CKA_ipd,
          RefSignalName           => "CKA",
          RefDelay                => 0 ns,
          SetupHigh               => tsetup_A0_CKA_posedge_posedge,
          SetupLow                => tsetup_A0_CKA_negedge_posedge,
          HoldHigh                => thold_A0_CKA_negedge_posedge,
          HoldLow                 => thold_A0_CKA_posedge_posedge,
          CheckEnabled            =>
                           NOW /= 0 ns AND CSA_ipd = '1',
          RefTransition           => 'R',
          HeaderMsg               => InstancePath & "/W1024_B8_BM2",
          Xon                     => Xon,
          MsgOn                   => MsgOn,
          MsgSeverity             => WARNING);

         VitalSetupHoldCheck (
          Violation               => Tviol_B_CKB_posedge,
          TimingData              => Tmkr_B_CKB_posedge,
          TestSignal              => B_ipd,
          TestSignalName          => "B",
          TestDelay               => 0 ns,
          RefSignal               => CKB_ipd,
          RefSignalName           => "CKB",
          RefDelay                => 0 ns,
          SetupHigh               => tsetup_B0_CKB_posedge_posedge,
          SetupLow                => tsetup_B0_CKB_negedge_posedge,
          HoldHigh                => thold_B0_CKB_negedge_posedge,
          HoldLow                 => thold_B0_CKB_posedge_posedge,
          CheckEnabled            =>
                           NOW /= 0 ns AND CSB_ipd = '1',
          RefTransition           => 'R',
          HeaderMsg               => InstancePath & "/W1024_B8_BM2",
          Xon                     => Xon,
          MsgOn                   => MsgOn,
          MsgSeverity             => WARNING);

         VitalSetupHoldCheck (
          Violation               => Tviol_WEAN_CKA_posedge,
          TimingData              => Tmkr_WEAN_CKA_posedge,
          TestSignal              => WEAN_ipd,
          TestSignalName          => "WEAN",
          TestDelay               => 0 ns,
          RefSignal               => CKA_ipd,
          RefSignalName           => "CKA",
          RefDelay                => 0 ns,
          SetupHigh               => tsetup_WEAN_CKA_posedge_posedge,
          SetupLow                => tsetup_WEAN_CKA_negedge_posedge,
          HoldHigh                => thold_WEAN_CKA_negedge_posedge,
          HoldLow                 => thold_WEAN_CKA_posedge_posedge,
          CheckEnabled            =>
                           NOW /= 0 ns AND CSA_ipd = '1',
          RefTransition           => 'R',
          HeaderMsg               => InstancePath & "/W1024_B8_BM2",
          Xon                     => Xon,
          MsgOn                   => MsgOn,
          MsgSeverity             => WARNING);
         VitalSetupHoldCheck (
          Violation               => Tviol_WEBN_CKB_posedge,
          TimingData              => Tmkr_WEBN_CKB_posedge,
          TestSignal              => WEBN_ipd,
          TestSignalName          => "WEBN",
          TestDelay               => 0 ns,
          RefSignal               => CKB_ipd,
          RefSignalName           => "CKB",
          RefDelay                => 0 ns,
          SetupHigh               => tsetup_WEBN_CKB_posedge_posedge,
          SetupLow                => tsetup_WEBN_CKB_negedge_posedge,
          HoldHigh                => thold_WEBN_CKB_negedge_posedge,
          HoldLow                 => thold_WEBN_CKB_posedge_posedge,
          CheckEnabled            =>
                           NOW /= 0 ns AND CSB_ipd = '1',
          RefTransition           => 'R',
          HeaderMsg               => InstancePath & "/W1024_B8_BM2",
          Xon                     => Xon,
          MsgOn                   => MsgOn,
          MsgSeverity             => WARNING);

         VitalSetupHoldCheck (
          Violation               => Tviol_DIA_CKA_posedge,
          TimingData              => Tmkr_DIA_CKA_posedge,
          TestSignal              => DIA_ipd,
          TestSignalName          => "DIA",
          TestDelay               => 0 ns,
          RefSignal               => CKA_ipd,
          RefSignalName           => "CKA",
          RefDelay                => 0 ns,
          SetupHigh               => tsetup_DIA0_CKA_posedge_posedge,
          SetupLow                => tsetup_DIA0_CKA_negedge_posedge,
          HoldHigh                => thold_DIA0_CKA_negedge_posedge,
          HoldLow                 => thold_DIA0_CKA_posedge_posedge,
          CheckEnabled            =>
                           NOW /= 0 ns AND CSA_ipd = '1' AND WEAN_ipd /= '1',
          RefTransition           => 'R',
          HeaderMsg               => InstancePath & "/W1024_B8_BM2",
          Xon                     => Xon,
          MsgOn                   => MsgOn,
          MsgSeverity             => WARNING);
         VitalSetupHoldCheck (
          Violation               => Tviol_DIB_CKB_posedge,
          TimingData              => Tmkr_DIB_CKB_posedge,
          TestSignal              => DIB_ipd,
          TestSignalName          => "DIB",
          TestDelay               => 0 ns,
          RefSignal               => CKB_ipd,
          RefSignalName           => "CKB",
          RefDelay                => 0 ns,
          SetupHigh               => tsetup_DIB0_CKB_posedge_posedge,
          SetupLow                => tsetup_DIB0_CKB_negedge_posedge,
          HoldHigh                => thold_DIB0_CKB_negedge_posedge,
          HoldLow                 => thold_DIB0_CKB_posedge_posedge,
          CheckEnabled            =>
                           NOW /= 0 ns AND CSB_ipd = '1' AND WEBN_ipd /= '1',
          RefTransition           => 'R',
          HeaderMsg               => InstancePath & "/W1024_B8_BM2",
          Xon                     => Xon,
          MsgOn                   => MsgOn,
          MsgSeverity             => WARNING);

         VitalSetupHoldCheck (
          Violation               => Tviol_CSA_CKA_posedge,
          TimingData              => Tmkr_CSA_CKA_posedge,
          TestSignal              => CSA_ipd,
          TestSignalName          => "CSA",
          TestDelay               => 0 ns,
          RefSignal               => CKA_ipd,
          RefSignalName           => "CKA",
          RefDelay                => 0 ns,
          SetupHigh               => tsetup_CSA_CKA_posedge_posedge,
          SetupLow                => tsetup_CSA_CKA_negedge_posedge,
          HoldHigh                => thold_CSA_CKA_negedge_posedge,
          HoldLow                 => thold_CSA_CKA_posedge_posedge,
          CheckEnabled            => NOW /= 0 ns,
          RefTransition           => 'R',
          HeaderMsg               => InstancePath & "/W1024_B8_BM2",
          Xon                     => Xon,
          MsgOn                   => MsgOn,
          MsgSeverity             => WARNING);

         VitalSetupHoldCheck (
          Violation               => Tviol_CSB_CKB_posedge,
          TimingData              => Tmkr_CSB_CKB_posedge,
          TestSignal              => CSB_ipd,
          TestSignalName          => "CSB",
          TestDelay               => 0 ns,
          RefSignal               => CKB_ipd,
          RefSignalName           => "CKB",
          RefDelay                => 0 ns,
          SetupHigh               => tsetup_CSB_CKB_posedge_posedge,
          SetupLow                => tsetup_CSB_CKB_negedge_posedge,
          HoldHigh                => thold_CSB_CKB_negedge_posedge,
          HoldLow                 => thold_CSB_CKB_posedge_posedge,
          CheckEnabled            => NOW /= 0 ns,
          RefTransition           => 'R',
          HeaderMsg               => InstancePath & "/W1024_B8_BM2",
          Xon                     => Xon,
          MsgOn                   => MsgOn,
          MsgSeverity             => WARNING);

         VitalPeriodPulseCheck (
          Violation               => Pviol_CKA,
          PeriodData              => Pdata_CKA,
          TestSignal              => CKA_ipd,
          TestSignalName          => "CKA",
          TestDelay               => 0 ns,
          Period                  => tperiod_CKA,
          PulseWidthHigh          => tpw_CKA_posedge,
          PulseWidthLow           => tpw_CKA_negedge,
          CheckEnabled            => NOW /= 0 ns AND CSA_ipd = '1',
          HeaderMsg               => InstancePath & "/W1024_B8_BM2",
          Xon                     => Xon,
          MsgOn                   => MsgOn,
          MsgSeverity             => WARNING);

         VitalPeriodPulseCheck (
          Violation               => Pviol_CKB,
          PeriodData              => Pdata_CKB,
          TestSignal              => CKB_ipd,
          TestSignalName          => "CKB",
          TestDelay               => 0 ns,
          Period                  => tperiod_CKB,
          PulseWidthHigh          => tpw_CKB_posedge,
          PulseWidthLow           => tpw_CKB_negedge,
          CheckEnabled            => NOW /= 0 ns AND CSB_ipd = '1',
          HeaderMsg               => InstancePath & "/W1024_B8_BM2",
          Xon                     => Xon,
          MsgOn                   => MsgOn,
          MsgSeverity             => WARNING);
   end if;

   -------------------------
   --  Functionality Section
   -------------------------

       if (CKA_ipd'event) then
         cka_change := LastClkAEdge&CKA_ipd;
         case cka_change is
            when "01"   =>
                if (CS_monitor(CSA_ipd,flag_CSA) = True_flg) then
                   -- Reduce error message --
                   flag_CSA := True_flg;
                else
                   flag_CSA := False_flg;
                end if;

                Latch_A      := A_ipd;
                Latch_CSA    := CSA_ipd;
                Latch_DIA   := DIA_ipd;
                Latch_WEAN  := WEAN_ipd;

                -- memory_functionA
                A_i    := Latch_A;
                CSA_i  := Latch_CSA;
                DIA_i  := Latch_DIA;
                WEAN_i := Latch_WEAN;

                wea_csa    := WEAN_i&CSA_i;
                case wea_csa is
                   when "11" =>
                       if (AddressRangeCheck(A_i,flag_A) = True_flg) then
                           if ((A_i = LastCycleBAddress) and
                               (Last_WEBN_i = '0') and
                               ((NOW-Last_tc_ClkB_PosEdge) < Tw2r)) then
                                 -- read and write the same address
                              assert FALSE report "** MEM_Warning: Read and Write the same address." severity WARNING;
                              DOA_zd := (OTHERS => 'X');
                              DOA_int <= TRANSPORT (OTHERS => 'X') AFTER TOH;
                           else
                              DOA_zd := memoryCore(to_integer(A_i));
                              ScheduleOutputDelay(DOA_int(0), DOA_zd(0),
                              tpd_CKA_DOA0_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(1), DOA_zd(1),
                              tpd_CKA_DOA1_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(2), DOA_zd(2),
                              tpd_CKA_DOA2_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(3), DOA_zd(3),
                              tpd_CKA_DOA3_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(4), DOA_zd(4),
                              tpd_CKA_DOA4_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(5), DOA_zd(5),
                              tpd_CKA_DOA5_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(6), DOA_zd(6),
                              tpd_CKA_DOA6_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(7), DOA_zd(7),
                              tpd_CKA_DOA7_posedge,last_A,A_i,NO_SER_TOH);
                           end if;
                           -- Reduce error message --
                           flag_A := True_flg;
                       end if;
                       LastCycleAAddress := A_i;

                   when "01" =>
                       if (AddressRangeCheck(A_i,flag_A) = True_flg) then
                           if (A_i = LastCycleBAddress) then
                              if ((Last_WEBN_i = '1') and ((NOW-Last_tc_ClkB_PosEdge) < Tr2w)) then
                                 -- read and write the same address
                                 assert FALSE report "** MEM_Warning: Read and Write the same address." severity WARNING;
                                 DOB_zd := (OTHERS => 'X');
                                 DOB_int <= TRANSPORT (OTHERS => 'X') AFTER TOH;
                                 memoryCore(to_integer(A_i)) := DIA_i;
                              elsif ((Last_WEBN_i = '0') and ((NOW-Last_tc_ClkB_PosEdge) < Tw2r)) then
                                 assert FALSE report "** MEM_Error: Port A and B write the same Address, core is unknown." severity WARNING;
                                 memoryCore(to_integer(A_i)) := (OTHERS => 'X');
                              else
                                 memoryCore(to_integer(A_i)) := DIA_i;
                              end if;
                           else
                              memoryCore(to_integer(A_i)) := DIA_i;
                           end if;
                           -- Reduce error message --
                           flag_A := True_flg;
                           -- write through --
                           DOA_zd := DIA_i;
                           ScheduleOutputDelay(DOA_int(0), DOA_zd(0),
                           tpd_CKA_DOA0_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(1), DOA_zd(1),
                           tpd_CKA_DOA1_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(2), DOA_zd(2),
                           tpd_CKA_DOA2_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(3), DOA_zd(3),
                           tpd_CKA_DOA3_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(4), DOA_zd(4),
                           tpd_CKA_DOA4_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(5), DOA_zd(5),
                           tpd_CKA_DOA5_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(6), DOA_zd(6),
                           tpd_CKA_DOA6_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(7), DOA_zd(7),
                           tpd_CKA_DOA7_posedge,last_A,A_i,NO_SER_TOH);
                       elsif (AddressRangeCheck(A_i,flag_A) = Range_flg) then
                           -- Reduce error message --
                           flag_A := False_flg;
                           --------------------------
                           -- write through --
                           DOA_zd := DIA_i;
                           ScheduleOutputDelay(DOA_int(0), DOA_zd(0),
                           tpd_CKA_DOA0_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(1), DOA_zd(1),
                           tpd_CKA_DOA1_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(2), DOA_zd(2),
                           tpd_CKA_DOA2_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(3), DOA_zd(3),
                           tpd_CKA_DOA3_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(4), DOA_zd(4),
                           tpd_CKA_DOA4_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(5), DOA_zd(5),
                           tpd_CKA_DOA5_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(6), DOA_zd(6),
                           tpd_CKA_DOA6_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(7), DOA_zd(7),
                           tpd_CKA_DOA7_posedge,last_A,A_i,NO_SER_TOH);
                       else
                           -- Reduce error message --
                           flag_A := False_flg;
                           --------------------------
                           DOA_zd := (OTHERS => 'X');
                           DOA_int <= TRANSPORT (OTHERS => 'X') AFTER TOH;
                           FOR i IN Words-1 downto 0 LOOP
                              memoryCore(i) := (OTHERS => 'X');
                           END LOOP;
                       end if;
                       LastCycleAAddress := A_i;
                   when "1X" |
                        "1U" |
                        "1Z"   =>
                       DOA_zd := (OTHERS => 'X');
                       DOA_int <= TRANSPORT (OTHERS => 'X') AFTER TOH;

                   when "10" |
                        "00" |
                        "X0" |
                        "U0" |
                        "Z0"   => -- do nothing
                   when others =>
                       DOA_zd := (OTHERS => 'X');
                       DOA_int <= TRANSPORT (OTHERS => 'X') AFTER TOH;
                       if (AddressRangeCheck(A_i,flag_A) = True_flg) then
                           memoryCore(to_integer(A_i)) := (OTHERS => 'X');
                       elsif (AddressRangeCheck(A_i,flag_A) = Range_flg) then
                           -- Reduce error message --
                           flag_A := False_flg;
                           --------------------------
                       else
                           FOR i IN Words-1 downto 0 LOOP
                              memoryCore(i) := (OTHERS => 'X');
                           END LOOP;
                       end if;
                end case;
                Last_WEAN_i := WEAN_i;
                -- end memory_functionA

                last_A := A_ipd;

                if (CSA_i = '1') then
                   Last_tc_ClkA_PosEdge := NOW;
                end if;
            when "10"   => -- do nothing
            when others => if (NOW /= 0 ns and CSA_ipd /= '0') then
                              assert FALSE report "** MEM_Error: Abnormal transition occurred." severity WARNING;
                              if (WEAN_ipd /= '1') then
                                 DOA_zd := (OTHERS => 'X');
                                 DOA_int <= TRANSPORT (OTHERS => 'X');
                                 FOR i IN Words-1 downto 0 LOOP
                                   memoryCore(i) := (OTHERS => 'X');
                                 END LOOP;
			      else
                                 DOA_int <= TRANSPORT (OTHERS => 'X');			      	
			      end if;	
                           end if;
         end case;
         LastClkAEdge := CKA_ipd;
       end if;

       if (CKB_ipd'event) then
         ckb_change := LastClkBEdge&CKB_ipd;
         case ckb_change is
            when "01"   =>
                if (CS_monitor(CSB_ipd,flag_CSB) = True_flg) then
                   -- Reduce error message --
                   flag_CSB := True_flg;
                else
                   flag_CSB := False_flg;
                end if;

                Latch_B      := B_ipd;
                Latch_CSB    := CSB_ipd;
                Latch_DIB   := DIB_ipd;
                Latch_WEBN  := WEBN_ipd;

                -- memory_functionB
                B_i    := Latch_B;
                CSB_i  := Latch_CSB;
                DIB_i  := Latch_DIB;
                WEBN_i := Latch_WEBN;

                web_csb    := WEBN_i&CSB_i;
                case web_csb is
                   when "11" =>
                       if (AddressRangeCheck(B_i,flag_B) = True_flg) then
                           if ((B_i = LastCycleAAddress) and
                               (Last_WEAN_i = '0') and
                               ((NOW-Last_tc_ClkA_PosEdge) < Tw2r)) then
                                 -- read and write the same address
                              assert FALSE report "** MEM_Warning: Read and Write the same address." severity WARNING;
                              DOB_zd := (OTHERS => 'X');
                              DOB_int <= TRANSPORT (OTHERS => 'X') AFTER TOH;
                           else
                              DOB_zd := memoryCore(to_integer(B_i));
                              ScheduleOutputDelay(DOB_int(0), DOB_zd(0),
                              tpd_CKB_DOB0_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(1), DOB_zd(1),
                              tpd_CKB_DOB1_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(2), DOB_zd(2),
                              tpd_CKB_DOB2_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(3), DOB_zd(3),
                              tpd_CKB_DOB3_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(4), DOB_zd(4),
                              tpd_CKB_DOB4_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(5), DOB_zd(5),
                              tpd_CKB_DOB5_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(6), DOB_zd(6),
                              tpd_CKB_DOB6_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(7), DOB_zd(7),
                              tpd_CKB_DOB7_posedge,last_B,B_i,NO_SER_TOH);
                           end if;
                           -- Reduce error message --
                           flag_B := True_flg;
                       end if;
                       LastCycleBAddress := B_i;

                   when "01" =>
                       if (AddressRangeCheck(B_i,flag_B) = True_flg) then
                           if (B_i = LastCycleAAddress) then
                              if ((Last_WEAN_i = '1') and ((NOW-Last_tc_ClkA_PosEdge) < Tr2w)) then
                                 -- read and write the same address
                                 assert FALSE report "** MEM_Warning: Read and Write the same address." severity WARNING;
                                 DOA_zd := (OTHERS => 'X');
                                 DOA_int <= TRANSPORT (OTHERS => 'X') AFTER TOH;
                                 memoryCore(to_integer(B_i)) := DIB_i;
                              elsif ((Last_WEAN_i = '0') and ((NOW-Last_tc_ClkA_PosEdge) < Tw2r)) then
                                 assert FALSE report "** MEM_Error: Port A and B write the same Address, core is unknown." severity WARNING;
                                 memoryCore(to_integer(B_i)) := (OTHERS => 'X');
                              else
                                 memoryCore(to_integer(B_i)) := DIB_i;
                              end if;
                           else
                              memoryCore(to_integer(B_i)) := DIB_i;
                           end if;
                           -- Reduce error message --
                           flag_B := True_flg;
                           -- write through --
                           DOB_zd := DIB_i;
                              ScheduleOutputDelay(DOB_int(0), DOB_zd(0),
                              tpd_CKB_DOB0_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(1), DOB_zd(1),
                              tpd_CKB_DOB1_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(2), DOB_zd(2),
                              tpd_CKB_DOB2_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(3), DOB_zd(3),
                              tpd_CKB_DOB3_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(4), DOB_zd(4),
                              tpd_CKB_DOB4_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(5), DOB_zd(5),
                              tpd_CKB_DOB5_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(6), DOB_zd(6),
                              tpd_CKB_DOB6_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(7), DOB_zd(7),
                              tpd_CKB_DOB7_posedge,last_B,B_i,NO_SER_TOH);
                       elsif (AddressRangeCheck(B_i,flag_B) = Range_flg) then
                           -- Reduce error message --
                           flag_B := False_flg;
                           --------------------------
                           -- write through --
                           DOB_zd := DIB_i;
                              ScheduleOutputDelay(DOB_int(0), DOB_zd(0),
                              tpd_CKB_DOB0_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(1), DOB_zd(1),
                              tpd_CKB_DOB1_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(2), DOB_zd(2),
                              tpd_CKB_DOB2_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(3), DOB_zd(3),
                              tpd_CKB_DOB3_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(4), DOB_zd(4),
                              tpd_CKB_DOB4_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(5), DOB_zd(5),
                              tpd_CKB_DOB5_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(6), DOB_zd(6),
                              tpd_CKB_DOB6_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(7), DOB_zd(7),
                              tpd_CKB_DOB7_posedge,last_B,B_i,NO_SER_TOH);
                       else
                           -- Reduce error message --
                           flag_B := False_flg;
                           --------------------------
                           DOB_zd := (OTHERS => 'X');
                           DOB_int <= TRANSPORT (OTHERS => 'X') AFTER TOH;
                           FOR i IN Words-1 downto 0 LOOP
                              memoryCore(i) := (OTHERS => 'X');
                           END LOOP;
                       end if;
                       LastCycleBAddress := B_i;
                   when "1X" |
                        "1U" |
                        "1Z"   =>
                       DOB_zd := (OTHERS => 'X');
                       DOB_int <= TRANSPORT (OTHERS => 'X') AFTER TOH;

                   when "10" |
                        "00" |
                        "X0" |
                        "U0" |
                        "Z0"   => -- do nothing
                   when others =>
                       DOB_zd := (OTHERS => 'X');
                       DOB_int <= TRANSPORT (OTHERS => 'X') AFTER TOH;
                       if (AddressRangeCheck(B_i,flag_B) = True_flg) then
                           memoryCore(to_integer(B_i)) := (OTHERS => 'X');
                       elsif (AddressRangeCheck(B_i,flag_B) = Range_flg) then
                           -- Reduce error message --
                           flag_B := False_flg;
                           --------------------------
                       else
                           FOR i IN Words-1 downto 0 LOOP
                              memoryCore(i) := (OTHERS => 'X');
                           END LOOP;
                       end if;
                end case;
                Last_WEBN_i := WEBN_i;
                -- end memory_functionB

                last_B := B_ipd;

                if (CSB_i = '1') then
                   Last_tc_ClkB_PosEdge := NOW;
                end if;
            when "10"   => -- do nothing
            when others => if (NOW /= 0 ns and CSB_ipd /= '0') then
                              assert FALSE report "** MEM_Error: Abnormal transition occurred." severity WARNING;
                              if (WEBN_ipd /= '1') then
                                 DOB_zd := (OTHERS => 'X');
                                 DOB_int <= TRANSPORT (OTHERS => 'X');
                                 FOR i IN Words-1 downto 0 LOOP
                                   memoryCore(i) := (OTHERS => 'X');
                                 END LOOP;
			      else
                                 DOB_int <= TRANSPORT (OTHERS => 'X');			      	
			      end if;
                           end if; 
         end case;
         LastClkBEdge := CKB_ipd;
       end if;

       -- timingcheck_violationA
       if (Tviol_A_CKA_posedge      = 'X' or
           Tviol_WEAN_CKA_posedge  = 'X' or
           Tviol_DIA_CKA_posedge   = 'X' or
           Tviol_CSA_CKA_posedge    = 'X' or
           Pviol_CKA                = 'X'
          ) then

         if (Pviol_CKA = 'X') then
            if (CSA_ipd /= '0') then
               if (WEAN_ipd /= '1') then
                  FOR i IN Words-1 downto 0 LOOP
                     memoryCore(i) := (OTHERS => 'X');
                  END LOOP;
               else
                  DOA_zd := (OTHERS => 'X');
                  DOA_int <= TRANSPORT (OTHERS => 'X');
               end if;
            end if;
         else
            FOR i IN AddressSize-1 downto 0 LOOP
              if (Tviol_A_CKA_posedge = 'X') then
                 Latch_A(i) := 'X';
              else
                 Latch_A(i) := Latch_A(i);
              end if;
            END LOOP;

            FOR i IN Bits-1 downto 0 LOOP
              if (Tviol_DIA_CKA_posedge = 'X') then
                 Latch_DIA(i) := 'X';
              else
                 Latch_DIA(i) := Latch_DIA(i);
              end if;
            END LOOP;

            if (Tviol_CSA_CKA_posedge = 'X') then
               Latch_CSA := 'X';
            else
               Latch_CSA := Latch_CSA;
            end if;
            if (Tviol_WEAN_CKA_posedge = 'X') then
               Latch_WEAN := 'X';
            else
               Latch_WEAN := Latch_WEAN;
            end if;
                -- memory_functionA
                A_i    := Latch_A;
                CSA_i  := Latch_CSA;
                DIA_i  := Latch_DIA;
                WEAN_i := Latch_WEAN;

                wea_csa    := WEAN_i&CSA_i;
                case wea_csa is
                   when "11" =>
                       if (AddressRangeCheck(A_i,flag_A) = True_flg) then
                           if ((A_i = LastCycleBAddress) and
                               (Last_WEBN_i = '0') and
                               ((NOW-Last_tc_ClkB_PosEdge) < Tw2r)) then
                                 -- read and write the same address
                              assert FALSE report "** MEM_Warning: Read and Write the same address." severity WARNING;
                              DOA_zd := (OTHERS => 'X');
                              DOA_int <= TRANSPORT (OTHERS => 'X') AFTER TOH;
                           else
                              DOA_zd := memoryCore(to_integer(A_i));
                              ScheduleOutputDelay(DOA_int(0), DOA_zd(0),
                              tpd_CKA_DOA0_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(1), DOA_zd(1),
                              tpd_CKA_DOA1_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(2), DOA_zd(2),
                              tpd_CKA_DOA2_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(3), DOA_zd(3),
                              tpd_CKA_DOA3_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(4), DOA_zd(4),
                              tpd_CKA_DOA4_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(5), DOA_zd(5),
                              tpd_CKA_DOA5_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(6), DOA_zd(6),
                              tpd_CKA_DOA6_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(7), DOA_zd(7),
                              tpd_CKA_DOA7_posedge,last_A,A_i,NO_SER_TOH);
                           end if;
                           -- Reduce error message --
                           flag_A := True_flg;
                       end if;
                       LastCycleAAddress := A_i;

                   when "01" =>
                       if (AddressRangeCheck(A_i,flag_A) = True_flg) then
                           if (A_i = LastCycleBAddress) then
                              if ((Last_WEBN_i = '1') and ((NOW-Last_tc_ClkB_PosEdge) < Tr2w)) then
                                 -- read and write the same address
                                 assert FALSE report "** MEM_Warning: Read and Write the same address." severity WARNING;
                                 DOB_zd := (OTHERS => 'X');
                                 DOB_int <= TRANSPORT (OTHERS => 'X') AFTER TOH;
                                 memoryCore(to_integer(A_i)) := DIA_i;
                              elsif ((Last_WEBN_i = '0') and ((NOW-Last_tc_ClkB_PosEdge) < Tw2r)) then
                                 assert FALSE report "** MEM_Error: Port A and B write the same Address, core is unknown." severity WARNING;
                                 memoryCore(to_integer(A_i)) := (OTHERS => 'X');
                              else
                                 memoryCore(to_integer(A_i)) := DIA_i;
                              end if;
                           else
                              memoryCore(to_integer(A_i)) := DIA_i;
                           end if;
                           -- Reduce error message --
                           flag_A := True_flg;
                           -- write through --
                           DOA_zd := DIA_i;
                           ScheduleOutputDelay(DOA_int(0), DOA_zd(0),
                           tpd_CKA_DOA0_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(1), DOA_zd(1),
                           tpd_CKA_DOA1_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(2), DOA_zd(2),
                           tpd_CKA_DOA2_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(3), DOA_zd(3),
                           tpd_CKA_DOA3_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(4), DOA_zd(4),
                           tpd_CKA_DOA4_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(5), DOA_zd(5),
                           tpd_CKA_DOA5_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(6), DOA_zd(6),
                           tpd_CKA_DOA6_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(7), DOA_zd(7),
                           tpd_CKA_DOA7_posedge,last_A,A_i,NO_SER_TOH);
                       elsif (AddressRangeCheck(A_i,flag_A) = Range_flg) then
                           -- Reduce error message --
                           flag_A := False_flg;
                           --------------------------
                           -- write through --
                           DOA_zd := DIA_i;
                           ScheduleOutputDelay(DOA_int(0), DOA_zd(0),
                           tpd_CKA_DOA0_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(1), DOA_zd(1),
                           tpd_CKA_DOA1_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(2), DOA_zd(2),
                           tpd_CKA_DOA2_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(3), DOA_zd(3),
                           tpd_CKA_DOA3_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(4), DOA_zd(4),
                           tpd_CKA_DOA4_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(5), DOA_zd(5),
                           tpd_CKA_DOA5_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(6), DOA_zd(6),
                           tpd_CKA_DOA6_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(7), DOA_zd(7),
                           tpd_CKA_DOA7_posedge,last_A,A_i,NO_SER_TOH);
                       else
                           -- Reduce error message --
                           flag_A := False_flg;
                           --------------------------
                           DOA_zd := (OTHERS => 'X');
                           DOA_int <= TRANSPORT (OTHERS => 'X') AFTER TOH;
                           FOR i IN Words-1 downto 0 LOOP
                              memoryCore(i) := (OTHERS => 'X');
                           END LOOP;
                       end if;
                       LastCycleAAddress := A_i;
                   when "1X" |
                        "1U" |
                        "1Z"   =>
                       DOA_zd := (OTHERS => 'X');
                       DOA_int <= TRANSPORT (OTHERS => 'X') AFTER TOH;

                   when "10" |
                        "00" |
                        "X0" |
                        "U0" |
                        "Z0"   => -- do nothing
                   when others =>
                       DOA_zd := (OTHERS => 'X');
                       DOA_int <= TRANSPORT (OTHERS => 'X') AFTER TOH;
                       if (AddressRangeCheck(A_i,flag_A) = True_flg) then
                           memoryCore(to_integer(A_i)) := (OTHERS => 'X');
                       elsif (AddressRangeCheck(A_i,flag_A) = Range_flg) then
                           -- Reduce error message --
                           flag_A := False_flg;
                           --------------------------
                       else
                           FOR i IN Words-1 downto 0 LOOP
                              memoryCore(i) := (OTHERS => 'X');
                           END LOOP;
                       end if;
                end case;
                Last_WEAN_i := WEAN_i;
                -- end memory_functionA
         end if;
       end if;
       -- end timingcheck_violationA

       -- timingcheck_violationB
       if (Tviol_B_CKB_posedge      = 'X' or
           Tviol_WEBN_CKB_posedge  = 'X' or
           Tviol_DIB_CKB_posedge   = 'X' or
           Tviol_CSB_CKB_posedge    = 'X' or
           Pviol_CKB                = 'X'
          ) then

         if (Pviol_CKB = 'X') then
            if (CSB_ipd /= '0') then
               if (WEBN_ipd /= '1') then
                  FOR i IN Words-1 downto 0 LOOP
                     memoryCore(i) := (OTHERS => 'X');
                  END LOOP;
               else
                  DOB_zd := (OTHERS => 'X');
                  DOB_int <= TRANSPORT (OTHERS => 'X');
               end if;
            end if;
         else
            FOR i IN AddressSize-1 downto 0 LOOP
              if (Tviol_B_CKB_posedge = 'X') then
                 Latch_B(i) := 'X';
              else
                 Latch_B(i) := Latch_B(i);
              end if;
            END LOOP;

            FOR i IN Bits-1 downto 0 LOOP
              if (Tviol_DIB_CKB_posedge = 'X') then
                 Latch_DIB(i) := 'X';
              else
                 Latch_DIB(i) := Latch_DIB(i);
              end if;
            END LOOP;

            if (Tviol_CSB_CKB_posedge = 'X') then
               Latch_CSB := 'X';
            else
               Latch_CSB := Latch_CSB;
            end if;
            if (Tviol_WEBN_CKB_posedge = 'X') then
               Latch_WEBN := 'X';
            else
               Latch_WEBN := Latch_WEBN;
            end if;
                -- memory_functionB
                B_i    := Latch_B;
                CSB_i  := Latch_CSB;
                DIB_i  := Latch_DIB;
                WEBN_i := Latch_WEBN;

                web_csb    := WEBN_i&CSB_i;
                case web_csb is
                   when "11" =>
                       if (AddressRangeCheck(B_i,flag_B) = True_flg) then
                           if ((B_i = LastCycleAAddress) and
                               (Last_WEAN_i = '0') and
                               ((NOW-Last_tc_ClkA_PosEdge) < Tw2r)) then
                                 -- read and write the same address
                              assert FALSE report "** MEM_Warning: Read and Write the same address." severity WARNING;
                              DOB_zd := (OTHERS => 'X');
                              DOB_int <= TRANSPORT (OTHERS => 'X') AFTER TOH;
                           else
                              DOB_zd := memoryCore(to_integer(B_i));
                              ScheduleOutputDelay(DOB_int(0), DOB_zd(0),
                              tpd_CKB_DOB0_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(1), DOB_zd(1),
                              tpd_CKB_DOB1_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(2), DOB_zd(2),
                              tpd_CKB_DOB2_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(3), DOB_zd(3),
                              tpd_CKB_DOB3_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(4), DOB_zd(4),
                              tpd_CKB_DOB4_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(5), DOB_zd(5),
                              tpd_CKB_DOB5_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(6), DOB_zd(6),
                              tpd_CKB_DOB6_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(7), DOB_zd(7),
                              tpd_CKB_DOB7_posedge,last_B,B_i,NO_SER_TOH);
                           end if;
                           -- Reduce error message --
                           flag_B := True_flg;
                       end if;
                       LastCycleBAddress := B_i;

                   when "01" =>
                       if (AddressRangeCheck(B_i,flag_B) = True_flg) then
                           if (B_i = LastCycleAAddress) then
                              if ((Last_WEAN_i = '1') and ((NOW-Last_tc_ClkA_PosEdge) < Tr2w)) then
                                 -- read and write the same address
                                 assert FALSE report "** MEM_Warning: Read and Write the same address." severity WARNING;
                                 DOA_zd := (OTHERS => 'X');
                                 DOA_int <= TRANSPORT (OTHERS => 'X') AFTER TOH;
                                 memoryCore(to_integer(B_i)) := DIB_i;
                              elsif ((Last_WEAN_i = '0') and ((NOW-Last_tc_ClkA_PosEdge) < Tw2r)) then
                                 assert FALSE report "** MEM_Error: Port A and B write the same Address, core is unknown." severity WARNING;
                                 memoryCore(to_integer(B_i)) := (OTHERS => 'X');
                              else
                                 memoryCore(to_integer(B_i)) := DIB_i;
                              end if;
                           else
                              memoryCore(to_integer(B_i)) := DIB_i;
                           end if;
                           -- Reduce error message --
                           flag_B := True_flg;
                           -- write through --
                           DOB_zd := DIB_i;
                              ScheduleOutputDelay(DOB_int(0), DOB_zd(0),
                              tpd_CKB_DOB0_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(1), DOB_zd(1),
                              tpd_CKB_DOB1_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(2), DOB_zd(2),
                              tpd_CKB_DOB2_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(3), DOB_zd(3),
                              tpd_CKB_DOB3_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(4), DOB_zd(4),
                              tpd_CKB_DOB4_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(5), DOB_zd(5),
                              tpd_CKB_DOB5_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(6), DOB_zd(6),
                              tpd_CKB_DOB6_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(7), DOB_zd(7),
                              tpd_CKB_DOB7_posedge,last_B,B_i,NO_SER_TOH);
                       elsif (AddressRangeCheck(B_i,flag_B) = Range_flg) then
                           -- Reduce error message --
                           flag_B := False_flg;
                           --------------------------
                           -- write through --
                           DOB_zd := DIB_i;
                              ScheduleOutputDelay(DOB_int(0), DOB_zd(0),
                              tpd_CKB_DOB0_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(1), DOB_zd(1),
                              tpd_CKB_DOB1_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(2), DOB_zd(2),
                              tpd_CKB_DOB2_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(3), DOB_zd(3),
                              tpd_CKB_DOB3_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(4), DOB_zd(4),
                              tpd_CKB_DOB4_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(5), DOB_zd(5),
                              tpd_CKB_DOB5_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(6), DOB_zd(6),
                              tpd_CKB_DOB6_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(7), DOB_zd(7),
                              tpd_CKB_DOB7_posedge,last_B,B_i,NO_SER_TOH);
                       else
                           -- Reduce error message --
                           flag_B := False_flg;
                           --------------------------
                           DOB_zd := (OTHERS => 'X');
                           DOB_int <= TRANSPORT (OTHERS => 'X') AFTER TOH;
                           FOR i IN Words-1 downto 0 LOOP
                              memoryCore(i) := (OTHERS => 'X');
                           END LOOP;
                       end if;
                       LastCycleBAddress := B_i;
                   when "1X" |
                        "1U" |
                        "1Z"   =>
                       DOB_zd := (OTHERS => 'X');
                       DOB_int <= TRANSPORT (OTHERS => 'X') AFTER TOH;

                   when "10" |
                        "00" |
                        "X0" |
                        "U0" |
                        "Z0"   => -- do nothing
                   when others =>
                       DOB_zd := (OTHERS => 'X');
                       DOB_int <= TRANSPORT (OTHERS => 'X') AFTER TOH;
                       if (AddressRangeCheck(B_i,flag_B) = True_flg) then
                           memoryCore(to_integer(B_i)) := (OTHERS => 'X');
                       elsif (AddressRangeCheck(B_i,flag_B) = Range_flg) then
                           -- Reduce error message --
                           flag_B := False_flg;
                           --------------------------
                       else
                           FOR i IN Words-1 downto 0 LOOP
                              memoryCore(i) := (OTHERS => 'X');
                           END LOOP;
                       end if;
                end case;
                Last_WEBN_i := WEBN_i;
                -- end memory_functionB
         end if;
       end if;
       -- end timingcheck_violationB

   end PROCESS;
end behavior;
