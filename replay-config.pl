#!/usr/bin/perl

## replay-config.pl based on g64conv and other code found on the net
## use to configure known Retro Replay ROMs (CyberpunX, SUPERFLUID, Final Replay)
## Stupid idea and copy/paste code by count0@pokefinder.org in 2021

### Do not remove the following lines, they ensure that
### perl2exe ( http://www.perl2exe.com ) can be used to
### make an executable that does not need an installed
### version of perl.

#perl2exe_include "PerlIO.pm"
#perl2exe_include "PerlIO/scalar.pm"
#perl2exe_include "utf8.pm"
#perl2exe_include "unicore/Heavy.pl"
#perl2exe_include "unicore/lib/Perl/_PerlIDS.pl"
#perl2exe_include "PerlIO.pm"
#perl2exe_include "File/Glob.pm"

use strict;
use warnings;
use 5.014;
use Digest::MD5;
use Fcntl qw(:seek);

#####################################################################################
my %knownroms = (
'cf2d20f59f61bb8b340cb30aa6310087'  => 'AR5',         #Action_Replay_V5.0_5.0_1988_PAL.bin
'b112d03ffd66f5be219605bde12239e5'  => 'AR5',         #Action_Replay_V5.0_5.0_1988_NTSC.bin
'427869da3bd5eabf036cae04325c03da'  => 'AR5',         #Action_Replay_V6.0_6.0_1989_PAL.bin
'235083e1ada79c46171bf6c5be1162bb'  => 'NordicPower', #Nordic_Power_v1.0_German_1989.bin
'ccd15e8d5a4edfb058b045f1b79bf77d'  => 'NordicPower', #Nordic_Power_v2.1_German_1989.bin
'098fbb365035d94a68dc2cfae19d67b9'  => 'NordicPower', #Nordic_Power_v7.2_German_1991.bin
'828273b27e210065d49ded859ec9cb2a'  => 'NordicPower', #Action_Power_v8.1_German_1994.bin
'e301c835341eb10ddde016098aa5cbbe'  => 'HTTP1',       #http64_20040707.bin
'b69559f4299b97c3143ff81dd88b58ba'  => 'HTTP1',       #http64_20040714.bin
'bc412a9282d5140ab406b378b46a42b5'  => 'HTTP2',       #http64_20040919.bin
'48c153123219e0584cc628312bf66161'  => 'DreaMon',     #DreaMon_0.4.1.bin
'8a3f299e340391b4591080beb7cb59b0'  => 'DreaMon',     #DreaMon_0.4.2.bin
'ae89abc25af814c7ebd4d47892fffec7'  => 'RR38A',       #rr-38a-64ntsc.bin
'5886d35a0b053ae35163aca651b7c43c'  => 'RR38A',       #rr-38a-64pal_20030414.bin
'96f060d76e92008c1502cd03711882a8'  => 'RR38A',       #rr-38a-64pal_20030917-Ninja.bin
'b9718a81cd29036fc6165ca529c9a13a'  => 'RR38A',       #rr-38a-64pal_20040502.bin
'300f23c358be2d75798de6b5faf0b895'  => 'RR38A',       #rr-38a-64pal_20041114.bin
'4424abf3ba7c9ec228ef2536298d95db'  => 'RR38A',       #RR-38a-64pal.bin
'000fdeb5e416c7bd9ee41354e7513d8d'  => 'RR38B',       #RR-38b-64pal.bin
'6fe0a110bf246077ff0168a7786cc0eb'  => 'RR38P',       #RR-3.8p_by_hannenz
'16c8e84452d6648685cb86e054b37402'  => 'RR38T',       #RR-3.8p_plus_TurboMacroPro_by_Devia
'3873bbd94ed2c71bb92a61f183422835'  => 'RR38T',       #RR-3.8p_plus_TurboMacroProREU_by_Devia
'f4300163ab2d68a38d08daf4051208e6'  => 'RR38T',       #RR-3.8p_pal_bugfixtmp12_Plum.bin
'7a19d314184056c046f23601b5b336dd'  => 'RR38T',       #RR-3.8p_pal_bugfixtmp12reu_Plum.bin
'21834dfcc0cdc7f261d2738307c4e0f4'  => 'RR38Q',       #RR-3.8q_with_CodeNet_by_j0ckstrap
'9104ec1f16a9b539068335d9eb3d7c99'  => 'RR38Y',       #RR-3.8y_ntsc_20110809.bin
'6f0b21be84859e32f227c56b437306c8'  => 'RR38Y',       #RR-3.8y_pal_20110809.bin
'9c2ad06064fec7ee7dce37cea3f28307'  => 'RR38T2',      #RR-3.8y_ntsc_tmp12m_20170103_polbit_breaks_spritekill.bin
'ace0775b3c0e97ff8aa109c211481b9e'  => 'RR38T2',      #RR-3.8y_ntsc_tmp12m_20170103_polbit_breaks_spritekill.crt
'ff75206c45442f61623095e1248f87e7'  => 'Superfluid',  #SUPERFLUID-0.1_menu.bin
'5c9682155b88d52c219033616cad46c0'  => 'Superfluid',  #SUPERFLUID-0.1.bin
'07d1d0bdfdc4135f0187c57f47155f14'  => 'Superfluid',  #SUPERFLUID-0.2_clean.bin
'7416b179c01bda61af757b7219cc923a'  => 'Superfluid',  #SUPERFLUID-0.2_menu.bin
'd143c0a29197826e1db00b71159828ed'  => 'Superfluid',  #SUPERFLUID-0.2.bin
'9cb233ba3c3fa221c3a7ab1a800e8c51'  => 'Superfluid',  #SUPERFLUID-0.3_clean.bin
'b2a950bd4df041eb128eff122ae4f288'  => 'Superfluid',  #SUPERFLUID-0.3_menu.bin
'd712681904e89e9cd0ce2fe676a62c80'  => 'Superfluid',  #SUPERFLUID-0.3.bin
'ea35850fec67782b3bca9ae1209b1adb'  => 'Superfluid',  #SUPERFLUID-0.4_clean.bin
'dd3f49bc7ba244a8d6ae6b647d9c7fa6'  => 'Superfluid',  #SUPERFLUID-0.4_menu.bin
'e810bf14c4b532c5883109cac8cb9709'  => 'Superfluid',  #SUPERFLUID-0.4.bin
'01cb409270b8faea76d8b62f92ca5c50'  => 'Superfluid',  #SUPERFLUID-0.5_clean.bin
'82cf0582afbd10987359da9e505b1a76'  => 'Superfluid',  #SUPERFLUID-0.5_menu.bin
'76c814fcd0fd5ba185323ab67334e058'  => 'Superfluid',  #SUPERFLUID-0.5.bin
'e0a20438de2978ee22eb58ad15b29959'  => 'Superfluid',  #SUPERFLUID-0.6-nr_clean.bin
'db8ce70c0bbe8ff9923ebeccd1d62d78'  => 'Superfluid',  #SUPERFLUID-0.6-nr_menu.bin
'8a48d15e8676ebf36bdf2389e59dd750'  => 'Superfluid',  #SUPERFLUID-0.6-nr.bin
'dd41bfff4aa439811c31d972bcc24ef7'  => 'Superfluid',  #SUPERFLUID-0.6-rr_clean.bin
'ec903dd6969bbd2d32692437a3d13266'  => 'Superfluid',  #SUPERFLUID-0.6-rr_menu.bin
'38bf82745de3f374220abd85b9eefa00'  => 'Superfluid',  #SUPERFLUID-0.6-rr.bin
'3158713558d977fbb02929cf013b06d6'  => 'Superfluid',  #SUPERFLUID-0.6-rx_clean.bin
'40460e0b6b8e48d0324c6d9288105b67'  => 'Superfluid',  #SUPERFLUID-0.6-rx_menu.bin
'8e2dd5257c32751cbdd587fb367abae6'  => 'Superfluid',  #SUPERFLUID-0.6-rx.bin
'7aaff08ca9d83bf98d72ee9f27d8168c'  => 'Superfluid',  #SUPERFLUID-0.7-nr_clean.bin
'7a2f49b34050ed05c4f8f1f8c6104a4b'  => 'Superfluid',  #SUPERFLUID-0.7-nr_menu.bin
'b4c041ce1c3528991d124f408a5417a3'  => 'Superfluid',  #SUPERFLUID-0.7-nr.bin
'1caf40a5112c757cae9254f25bdd603a'  => 'Superfluid',  #SUPERFLUID-0.7-rr_clean.bin
'9ce9ebf1befd0f390ead87dd5facf6a9'  => 'Superfluid',  #SUPERFLUID-0.7-rr_menu.bin
'8757d60a18d654c07d793efd7d0fe036'  => 'Superfluid',  #SUPERFLUID-0.7-rr.bin
'10b7e40763a439300456d75f64bb4aae'  => 'Superfluid',  #SUPERFLUID-0.7-rx_clean.bin
'976142b2635ee8252cdf85eb378e21e1'  => 'Superfluid',  #SUPERFLUID-0.7-rx_menu.bin
'8d6d90cec487edb881084ddeed4dc712'  => 'Superfluid',  #SUPERFLUID-0.7-rx.bin
'8938c3d6a2bfd0f261656f0199eb7c75'  => 'TAR1',        #tar_v1_pal.bin
'3b756e7bccdda9e449f928c28195607a'  => 'TAR2',        #tar_v2_ntsc.bin
'81798a8c791eae9fcd96cb30181b0c50'  => 'TAR2',        #tar_v2_pal.bin
'fffb33a35900a1dcc057376f636eba56'  => 'TFR0',        #tfr01.rom
'4f3fcea8f88120162233f6ebc9500dbb'  => 'TFR0',        #tfr02.rom
'205ca6bc8108c8960f7e2a8136c0bea4'  => 'TFR7',        #tfr03.rom
'4242cf10a67acf66980e643cab661ea2'  => 'TFR7',        #tfr04.rom
'012c2fdf2dd7b29fe36efe058ee73d2d'  => 'TFR7',        #tfr05.rom
'a0812db253aaa941d3792eab952f490d'  => 'TFR7',        #tfr06.rom
'385a20e12495d8b34b7c06c493e193e8'  => 'TFR7',        #tfr07.bin
'126418de6cbe754728af038d38acd6e8'  => 'TFR8'         #tfr08.bin
);

#####################################################################################
# for header detection

my @romvalues = ( 
                                                # Action Replay 5/6
  [ "AR5",   0x0668, 0x56, 0x066a, 0x2e, 0x066b, 0x30, 0x0088, 0x29 ],
                                                # Retro Replay 3.8P (with TMP patches)
  [ "RR38T", 0x0080, 0x52, 0x0081, 0x52, 0x0082, 0x33, 0x0083, 0x38, 0x0084, 0x50, 0x81ba, 0x4c, 0x81bb, 0x00, 0x81bc, 0x80 ],
                                                # Retro Replay 3.8Q (j0x)
  [ "RR38Q", 0x0080, 0x52, 0x0081, 0x52, 0x0082, 0x33, 0x0083, 0x38, 0x0084, 0x51, 0x2568, 0x4e, 0x2569, 0x45, 0x256a, 0xd4 ],
                                                # Retro Replay 3.8P (hannenz only)
  [ "RR38P", 0x0080, 0x52, 0x0081, 0x52, 0x0082, 0x33, 0x0083, 0x38, 0x0084, 0x50 ],
                                                # Retro Replay 3.8B
  [ "RR38B", 0x0080, 0x52, 0x0081, 0x52, 0x0082, 0x33, 0x0083, 0x38, 0x0084, 0x42 ],
                                                # Retro Replay 3.8A
  [ "RR38A", 0x0080, 0x52, 0x0081, 0x52, 0x0082, 0x33, 0x0083, 0x38, 0x0084, 0x41 ],
                                                # CyberpunX Replay 3.99
  [ "CR399", 0x0080, 0x43, 0x0081, 0x52, 0x0082, 0x33, 0x0083, 0x39, 0x0084, 0x39 ],
                                                # Turbo Action ROM v1
  [ "TAR1",  0x0000, 0x09, 0x0001, 0x80, 0x1e73, 0x00, 0x210f, 0x46 ],
                                                # Turbo Action ROM v2
  [ "TAR1",  0x0000, 0x73, 0x0001, 0x9e, 0x1e73, 0xa9, 0x210f, 0x46 ],
                                                # The Final Replay 0.7 (to detect modified ROMs)
  [ "TFR7",  0x216a, 0x30, 0x216b, 0x2e, 0x216c, 0x37, 0x21f4, 0xb0 ],
                                                # The Final Replay 0.8 (to detect modified ROMs)
  [ "TFR8",  0x216a, 0x30, 0x216b, 0x2e, 0x216c, 0x38, 0x21f4, 0xb4 ],
                                                # HTTP-Load (20040707 20040714)
  [ "HTTP1", 0x1f23, 0xa2, 0x1f24, 0x08, 0x1f25, 0x20, 0x1f26, 0x00, 0x1f27, 0x01, 0x1f28, 0x4c, 0x1f29, 0xa9 ],
                                                # HTTP-Load2 (20040919)
  [ "HTTP2", 0x1f23, 0xa2, 0x1f24, 0x08, 0x1f25, 0x20, 0x1f26, 0x00, 0x1f27, 0x01, 0x1f28, 0x4c, 0x1f29, 0xb7 ]

);

#####################################################################################
my $debug = 0;


if (@ARGV < 1)
  {  help();  }

my ($filename, $outputfile) = @ARGV;

my($fh, $byte_position, $byte_value, $rommd5, $editrom);
my $romChange = 0;
my $size = 0;
my @rombuffer;

  readROM($filename);

  $editrom = identifyROM();

  $editrom =~ /^AR5/   ? configAR5() :
  $editrom =~ /^sf/    ? configSF() :
  $editrom =~ /^TFR0/  ? configTFR0() :
  $editrom =~ /^TFR/   ? configTFR() :
  $editrom =~ /^TAR1/  ? configAR5() :
  $editrom =~ /^TAR2/  ? configTAR2() :
  $editrom =~ /^HTTP/  ? configHTTP() :
  $editrom =~ /^RR38/  ? configRR() :
                         configExit();


#####################################################################################

sub configRR
{
  print "Retro Replay 3.8x:\n\n";


  if ($editrom =~ /^RR38A/) 
  {  die "WARNING! Do NOT use 3.8A (ALPHA) ROMS!\nA serious LOAD issue will affect usability too much!\nExiting.\n"; }

  if ($editrom =~ /^RR38T2/) 
  {
     print "WARNING! This patched 3.8Y TMP1.2 version from retrohackers breaks the Freezers' Spritekiller!\n\n";
  }


  my $baseOffset = 0x0080;

  my $fill = getHEX($baseOffset+0x15);
  my $fillnew = askHEX($fill,"HEX for fill value #1");
    if ( $fill ne $fillnew ) {
      patchBYTE($baseOffset+0x15, "0x".$fillnew);
    }

  my $key = getSTRING($baseOffset+0x17,0);
  my $keynew = askSTRING($key,"\nStartup menu key for fill value #1", $key);
    if ( $key ne $keynew ) {
      patchSTRING($baseOffset+0x17, $keynew, 0, $key);
    }

  print "-" x 20 . "\n";

  my $fill2 = getHEX($baseOffset+0x16);
  my $fill2new = askHEX($fill2,"HEX for fill value #2");
    if ( $fill2 ne $fill2new ) {
      patchBYTE($baseOffset+0x16, "0x".$fill2new);
    }

  my $key2 = getSTRING($baseOffset+0x18,0);
  my $key2new = askSTRING($key2,"\nStartup menu key for fill value #2", $key2);
    if ( $key2 ne $key2new ) {
      patchSTRING($baseOffset+0x18, $key2new, 0, $key2);
    }

  print "-" x 20 . "\n";

# initial fastload
# $01 == enabled
  my $fastload = getHEX($baseOffset+0x19);
  
  if ( $fastload == 0x01 )
   { 
    print "Default fastload currently enabled.\n"; 
    if ( prompt_yn("Disable default cartridge fastload (to use kernal)", "n") ) {
     printf "offset %04x original value: %02x\n", $baseOffset+0x19, ord($rombuffer[$baseOffset+0x19]) if $debug;
     $rombuffer[$baseOffset+0x19] = pack( "C", 0x00);
     printf "offset %04x patchED  value: %02x \n", $baseOffset+0x19, ord($rombuffer[$baseOffset+0x19]) if $debug;
     $romChange++;
   }
  } else {
    print "Default fastload currently disabled.\n"; 
    if ( prompt_yn("Enable default cartridge fastload", "y") ) {
     printf "offset %04x original value: %02x\n", $baseOffset+0x19, ord($rombuffer[$baseOffset+0x19]) if $debug;
     $rombuffer[$baseOffset+0x19] = pack( "C", 0x01);
     printf "offset %04x patchED  value: %02x \n", $baseOffset+0x19, ord($rombuffer[$baseOffset+0x19]) if $debug;
     $romChange++;
   }
  }

  print "-" x 20 . "\n";

  my $owner = getSTRING($baseOffset+5,15);
  my $ownernew = askSTRING($owner,"Owner string", $owner);

    if ( $owner ne $ownernew ) {
      patchSTRING($baseOffset+5, $ownernew, 15, 0x20);
    }


  if ($editrom =~ /^RR38T/) 
  {
    print "-" x 20 . "\n";
    print "Turbo Ass Macro Pro enabled ROM found!\n\n";

    my $color;
    if ( prompt_yn("Edit Turbo Assembler default colors?", "n") ) {
      editCOL(0xa11b, "Border color");
      editCOL(0xa11c, "Screen color");
      editCOL(0xa11d, "Command line color");
      editCOL(0xa11e, "Status line color");
      editCOL(0xa11f, "Text color");
      editCOL(0xa120, "Error color");
      editCOL(0xa121, "Marked color");
    }
  }


  if ($editrom =~ /^RR38Q/) 
  {
    print "-" x 20 . "\n";
    print "CODENET config:\n\n";

    my $ipc64 = getIP(0x592d);
    my $newipc64 = askIP($ipc64, "C64 IP");
    if ( $ipc64 ne $newipc64 ) {
      patchIP(0x592d, $newipc64);
    }

    my $currMAC = getMAC(0x5927);
    my $newMAC = askMAC($currMAC);
    if ( $currMAC ne $newMAC ) {
      patchMAC(0x5927,$newMAC);
    }
  }

  writeROM();
}




sub configHTTP
{
  print "HTTP-Load2:\n\n";

  my $baseOffset;
  if ($editrom =~ /^HTTP2/) 
  {
    $baseOffset = 0x2263;
    print "Handling for: http64.bin (20040919)\n\n";
    } else {
    $baseOffset = 0x21c3;
    print "Handling for: http64.bin (20040714, 20040707)\n\n";
  }

  print "-" x 20 . "\n";

  my $ipc64 = getIP($baseOffset);
  my $newipc64 = askIP($ipc64, "C64 IP");

  my $currMAC = getMAC($baseOffset+4);
  my $newMAC = askMAC($currMAC, "00:80:10:16:32:64");

  my $maskc64 = getIP($baseOffset+10);
  my $newmaskc64 = askMASK($maskc64, "Netmask");

  my $ippc = getIP($baseOffset+14);
  my $newippc = askIP($ippc, "Gateway IP");

  my $ipdns = getIP($baseOffset+18);
  my $newipdns = askDNS($ipdns, "DNS IP","8.8.8.8");

  if ($editrom =~ /^HTTP2/) {
    my $loadcmd = getSTRING(0x2087,46);
    my $loadnew = askSTRING($loadcmd,"LOAD string on startup", "load\"rr.c64.org/FB.prg\",32");

    if ( $loadcmd ne $loadnew ) {
      patchSTRING(0x2087, $loadnew, 46, 0x20);
    }
  }

  if ( $newipc64 ne $newippc ) {
    patchIP($baseOffset, $newipc64);
    patchIP($baseOffset+10, $newmaskc64);
    patchIP($baseOffset+14, $newippc);
    patchIP($baseOffset+18, $newipdns);
  }

  if ( $currMAC ne $newMAC ) {
    patchMAC($baseOffset+4,$newMAC);
  }
  writeROM();
}



sub configTAR2
{
  print "Turbo Action ROM v2:\n\n";

  if ( prompt_yn("Do you want to disable \"ARE YOU SURE?\" on this ROM ", "y") ) {
    disableUSURE();
  }

  my $ipc64 = getIP(0xebc3);
  my $newipc64 = askIP($ipc64, "C64 IP");

  my $maskc64 = getIP(0xebc7);
  my $newmaskc64 = askMASK($maskc64, "Netmask");

  my $ippc = getIP(0xebcb);
  my $newippc = askIP($ippc, "Gateway IP");

  if ( $newipc64 ne $newippc ) {
    patchIP(0xebc3, $newipc64);
    patchIP(0xebc7, $newmaskc64);
    patchIP(0xebcb, $newippc);
  }
  writeROM();
}



sub configTFR
{
  print "The Final Replay (0.3 to 0.8):\n\n";

  my $currMAC = getMAC(0x1000);
  my $newMAC = askMAC($currMAC);

  if ( $currMAC ne $newMAC ) {
    patchMAC(0x1000,$newMAC);
    patchMAC(0x7e00,$newMAC);
  }

  my $ipc64 = getIP(0x1006);
  my $newipc64 = askIP($ipc64, "C64 IP");

  my $ippc = getIP(0x100c);
  my $newippc = askIP($ippc, "PC IP");


  if ( $newipc64 ne $newippc ) {
  my $ipsum = calcIPSUM($newipc64, $newippc);

    patchIPSUM(0x1012, $ipsum);
    patchIP(0x1006, $newipc64);
    patchIP(0x100c, $newippc);
      if ( $editrom =~ /^TFR7/ ) {
        patchIP(0x7e06, $newipc64);
      }
  }
  writeROM();
}



sub configAR5
{
  print "Action Replay 5/6, Turbo Action ROM v1:\n\n";
  if ( prompt_yn("Do you want to disable \"ARE YOU SURE?\" on this ROM ", "y") ) {
    disableUSURE();
  }
  writeROM();
}



sub configSF
{    print "- Sorry, detected SUPERFLUID but there are not config options for me."; }

sub configTFR0
{    print "- Sorry, detected The Final Replay 0.1/0.2 but there are not config options for me."; }

sub configExit
{    print "- Sorry, cant help with this one.\n\n"; }

#####################################################################################
sub editCOL
{
    my ($offset,$query) = @_;
    my $ccol = sprintf "%x", ord($rombuffer[$offset]);;
    my $ask = prompt_col("$query (currently: $ccol)", $ccol);

    if ( $ask ne $ccol ) {
      patchBYTE($offset, "0x".$ask);
    }

    return $ask;
}

sub disableUSURE
{
# Disable "Are you sure?" - ar 5/6/tar v1/2
# patches:
# 8b3a bmi 8b53  == offset: 4b3a - $30 $17

  my @ar5values = ( 0x4b3a, 0x30, 0x4b3b, 0x17 );

  for (my $i=0; $i <= $#ar5values; $i+=2 ) {

     printf "offset %04x original value: %02x\n", $ar5values[$i], ord($rombuffer[$ar5values[$i]]) if $debug;
     $rombuffer[$ar5values[$i]] = pack( "C", $ar5values[$i+1]);
     printf "offset %04x patchED  value: %02x \n", $ar5values[$i], ord($rombuffer[$ar5values[$i]]) if $debug;
  }
  $romChange++;
}


sub patchMAC
{
  my ($moffset, $macadr) = @_;
  my @maccies = split /[:-]/, $macadr;

  for (my $i=0; $i <= $#maccies; $i++ ) {

    my $newval = hex $maccies[$i];
     printf "offset %04x original value: %02x \n", $moffset+$i, ord($rombuffer[$moffset+$i]) if $debug;
     printf "offset %04x patch    value: %02x \n", $moffset+$i, $newval if $debug;
     $rombuffer[$moffset+$i] = pack( "C", $newval);
     printf "offset %04x patchED  value: %02x \n", $moffset+$i, ord($rombuffer[$moffset+$i]) if $debug;
  }
  $romChange++;
}


sub patchIP
{
  my ($ipoffset, $ipadr) = @_;
  my @ips = split /[.]/, $ipadr;

  for (my $i=0; $i <= $#ips; $i++ ) {

    my $newval = $ips[$i];
     printf "offset %04x original value: %02x \n", $ipoffset+$i, ord($rombuffer[$ipoffset+$i]) if $debug;
     printf "offset %04x patch    value: %02x \n", $ipoffset+$i, $newval if $debug;
     $rombuffer[$ipoffset+$i] = pack( "C", $newval);
     printf "offset %04x patchED  value: %02x \n", $ipoffset+$i, ord($rombuffer[$ipoffset+$i]) if $debug;
  }
  $romChange++;
}


sub patchIPSUM
{
# weird - the precalced ipsum is written as HIGH-/LOW-value into the file
# as seen on setip by Graham

  my ($ipoffset, $ipchk) = @_;

  my $newval = substr (sprintf ("%04x", $ipchk), 0,2);
  $newval = sprintf("%d", hex($newval));

  my $newval2 = substr (sprintf ("%04x", $ipchk), 2,2);
  $newval2 = sprintf("%d", hex($newval2));

    printf "offset %04x original value: %02x \n", $ipoffset, ord($rombuffer[$ipoffset]) if $debug;
    printf "offset %04x patch    value: %02x \n", $ipoffset, $newval if $debug;
    $rombuffer[$ipoffset] = pack( "C", $newval);
    printf "offset %04x patchED  value: %02x \n", $ipoffset, ord($rombuffer[$ipoffset]) if $debug;

    printf "offset %04x original value: %02x \n", $ipoffset+1, ord($rombuffer[$ipoffset+1]) if $debug;
    printf "offset %04x patch    value: %02x \n", $ipoffset+1, $newval2 if $debug;
    $rombuffer[$ipoffset+1] = pack( "C", $newval2);
    printf "offset %04x patchED  value: %02x \n", $ipoffset+1, ord($rombuffer[$ipoffset+1]) if $debug;
  $romChange++;
}


sub patchBYTE
{
  my ($offset, $val) = @_;
  my $newval = hex $val;

    printf "offset %04x original value: %02x \n", $offset, ord($rombuffer[$offset]) if $debug;
    printf "offset %04x patch    value: %02x \n", $offset, $newval if $debug;
    $rombuffer[$offset] = pack( "C", $newval);
    printf "offset %04x patchED  value: %02x \n", $offset, ord($rombuffer[$offset]) if $debug;
  $romChange++;
}

#####################################################################################
sub askMAC
{
  my ($mac,$bettermac) = @_;
  if ( !defined($bettermac) ) { $bettermac = $mac; }
  my $ask = prompt_mac("Enter MAC-Address: (currently: $mac)", $bettermac);
  print "\nGot: " . $ask . "\n" if $debug;
  return $ask;
}


sub getMAC
{
  my ($moffset) = @_;
  my $mac = sprintf "%02x:%02x:%02x:%02x:%02x:%02x", 
                  ord($rombuffer[$moffset]),ord($rombuffer[$moffset+1]),
                  ord($rombuffer[$moffset+2]),ord($rombuffer[$moffset+3]),
                  ord($rombuffer[$moffset+4]),ord($rombuffer[$moffset+5]);
  return $mac;
}


sub askMASK
{
  my ($ip,$machine) = @_;
  my $ask = prompt_mask("Enter $machine: (currently: $ip)", $ip);
  print "\nGot: " . $ask . "\n" if $debug;
  return $ask;
}


sub askIP
{
  my ($ip,$machine,$betterip) = @_;
  if ( !defined($betterip) ) { $betterip = $ip; }
  my $ask = prompt_ip("Enter $machine: (currently: $ip)", $betterip);
  print "\nGot: " . $ask . "\n" if $debug;
  return $ask;
}

sub askDNS
{
  my ($ip,$machine,$betterip) = @_;
  if ( !defined($betterip) ) { $betterip = $ip; }
  my $ask = prompt_dns("Enter $machine: (currently: $ip)", $betterip);
  print "\nGot: " . $ask . "\n" if $debug;
  return $ask;
}

sub askHEX
{
  my ($hex,$machine) = @_;
  my $ask = prompt_hex("Enter $machine (currently: $hex)", $hex);
  print "\nGot: " . $ask . "\n" if $debug;
  return $ask;
}

sub getIP
{

  my ($ipoffset) = @_;
  my $ip = sprintf "%d.%d.%d.%d", 
                  ord($rombuffer[$ipoffset]),ord($rombuffer[$ipoffset+1]),
                  ord($rombuffer[$ipoffset+2]),ord($rombuffer[$ipoffset+3]);
  return $ip;
}


sub getDEC 
{
# unused so far
  my ($offset) = @_;
  return sprintf "%d", ord($rombuffer[$offset]);
}

sub getHEX
{

  my ($offset) = @_;
  return sprintf "%02x", ord($rombuffer[$offset]);
}

sub calcIPSUM
{
# special stuff for TFR - as seen on Graham's setip.cpp

  my ($ip1, $ip2) = @_;

  my @ip1s = split /[.]/, $ip1;
  my @ip2s = split /[.]/, $ip2;

  my $nipsum = ($ip1s[2] * 256) + $ip1s[3] +
              $ip1s[0] * 256 + $ip1s[1] + 
              ($ip2s[2] * 256) + $ip2s[3] +
              $ip2s[0] * 256 + $ip2s[1];

  while ( $nipsum > 65535 )
  {
    $nipsum = $nipsum - 65535;
  }
  return $nipsum;
}

#####################################################################################
# ugly string stuff on binaries

sub askSTRING
{
  my ($text,$machine,$bettertext) = @_;
  if ( !defined($bettertext) ) { $bettertext = $text; }

    #print "UH! PETSCII text entry on a console :)\n";
    #print "Avoid special characters for your own sake.\n\n";

  print $machine . "\nCurrently: (" . $text . ")  Default: [" . $bettertext . "]\n";

  my $answer = prompt("Your choice: ");

  print "\nGot: " . $answer . "\n" if $debug;

  if ( $answer eq "" )
  { print "Empty input or or unhandled text. Using default: ". $bettertext . "\n"; return $bettertext; }
  else { return $answer; }
}

sub getSTRING
{
  my ($stringoffset,$stringlength) = @_;
  my $string = "";
  my $char;

  for (my $i=0; $i <= $stringlength; $i++ ) {
    my $char = petscii_to_ascii(ord($rombuffer[$stringoffset+$i]));

    $string = $string . $char;

  }
  return $string;
}

sub patchSTRING
{
  my ($stringoffset,$string, $stringlength, $stringpad) = @_;
  my $char;

  for (my $i=0; $i <= $stringlength; $i++ ) {

    my $char = (length($string) > $i ? ord(ascii_to_petscii(substr($string, $i, 1))) : $stringpad);

    printf "offset %04x original value: %02x \n", $stringoffset+$i, ord($rombuffer[$stringoffset+$i]) if $debug;
    printf "offset %04x patch    value: %02x \n", $stringoffset+$i, $char if $debug;
    $rombuffer[$stringoffset+$i] = pack( "C", $char);
    printf "offset %04x patchED  value: %02x \n", $stringoffset+$i, ord($rombuffer[$stringoffset+$i]) if $debug;
  }
  $romChange++;
}

#####################################################################################
# read, write and identify roms

sub readROM
{
# basic read and size checks - then load file into array

  open($fh, "<", $filename) || die "Can't open $filename: $!\n";
  binmode($fh) || die "Can't binmode $filename\n";

  $size = -s $filename;

  if ( ($size != 32768 ) && ($size != 65536 ) )
   {
      print "This file SEEMS invalid - size should be 32768 or 65536 bytes.\n";
      print "Script only handles ROMs in straight binary format without start address.\n";
      die "No .CRT files either. Sorry.\n";
   }

  $rommd5 = Digest::MD5->new->addfile($fh)->hexdigest;

  my $total_read = 0;

    open F, "< $filename"
        or die "can't open $filename\n";

  my $buffer;

  while ( my $read = sysread(F , $buffer , 1,  ) )
    {
        push(@rombuffer, $buffer);
        $total_read += $read;
    }
}


sub writeROM
{
# Save only happens for changed roms and overwriting should only work with debug on

  print "-" x 20 . "\n";

  my $outfile = "";
  my $answer;

  if ($romChange > 0 ) {

    if ( defined $outputfile )
     { $outfile = $outputfile; } else
     { $outfile = $filename . "~" if $debug; }

    while ( $outfile eq "" ) {
     $answer = prompt("ROM save filename: ");
     if ( $answer ne "" ) { $outfile = $answer; }
    }

    while ( -e $outfile ) {
      print "Save file exists!\n";
      $answer = prompt("ROM save filename [$outfile]: ");
      if ( $answer ne "" ) { $outfile = $answer; }
      if ( $answer eq "" && $debug > 0 )
         { print "Empty input or unhandled text. Using: ". $outfile . "\n"; last; }
     }

    open($fh, ">", $outfile) || die "Can't open $outfile: $!\n";
    binmode($fh) || die "Can't binmode $outfile\n";

    for my $i (0 .. $#rombuffer) {
      syswrite $fh, $rombuffer[$i];
    }

    close($fh) || warn "Close failed: $!"; ;
    print "Wrote $outfile\n\n";

  } else {
    print "\n- No changes were made to the binary.\n\n"
  }
}


sub identifyROM
{
# looks at the md5 list and returns the name of a pre-set to use for config

  my $var = $knownroms{$rommd5};               # check md5 against list above

  if (!defined($var)) { $var = "unknown"; }  # unidentified based on md5
  print "=" x 60;
  print "\nMD5sum: " . $rommd5 . " for " . $filename . " - " . $var . " ROM\n";

# uses the romvalues array to determine a ROM based on the header - possibly overriding md5
 for my $i (0 .. $#romvalues) {

  print "Looking for: " . $romvalues[$i][0] . "\n" if $debug;
  my $match = 1;

  for (my $k=1; $k <= $#{ $romvalues[$i] }; $k+=2 ) {

     printf "offset %04x value: %02x \n", $romvalues[$i][$k], ord($rombuffer[$romvalues[$i][$k]]) if $debug;
     printf "compare to   : %02x \n", $romvalues[$i][$k+1] if $debug;

     if ( $romvalues[$i][$k+1] != ord($rombuffer[$romvalues[$i][$k]]) ) {
      $match=0;
      last;
     }
  }

  if ($match==1) { 
    $var = $romvalues[$i][0];
    last;
  }

  print "Nothing found based on known header values.\n" if $match==0 && $debug;
 }
  print "Found: " . $var . " (internal naming)\n";
  print "=" x 60 . "\n";

  return $var;  # a real type for edit choices
}

#####################################################################################
# some stackoverflow findings

sub prompt {
  my ($query) = @_; # take a prompt string as argument
  my $line;
  local $| = 1; # activate autoflush to immediately show the prompt
  while ( (print $query), $line = <STDIN>, $line !~ /^\s*$/)
  {
    $line =~ s/^\s*//;      # delete leading spaces
    $line =~ s/\s*$//;      # delete trailing spaces
                            # no chomp is needed because both
                            # carriage return and line feed are
                            # white space characters (\s) in Perl
                            # regex lingo
    print "Data processed:$line\n" if $debug;
    return $line;
  }
}

sub prompt_yn {
  my ($query, $default) = @_;
  my $default_yes = lc $default eq 'y';
  my $yn = $default_yes ? "[Y/n]" : "[y/N]";
  my $answer = lc prompt("$query $yn: ");
  return $default_yes ? ! ($answer =~ /^n/) : $answer =~ /^y/;
}

sub prompt_mac {
  my ($query, $default) = @_;
  my $default_mac = lc $default;
  my $answer = lc prompt("$query [$default_mac]: ");

  if ( $answer =~ /^(?:[[:xdigit:]]{2}([-:]))(?:[[:xdigit:]]{2}\1){4}[[:xdigit:]]{2}$/ )
    { return $answer; } else { print "Using default: ". $default_mac ."\n"; return $default_mac; }
}

sub prompt_mask {
  my ($query, $default) = @_;
  my $default_mask = lc $default;
  my $answer = lc prompt("$query [$default_mask]: ");

  if ( $answer =~ /^(((255\.){3}(255|254|252|248|240|224|192|128|0+))|((255\.){2}(255|254|252|248|240|224|192|128|0+)\.0)|((255\.)(255|254|252|248|240|224|192|128|0+)(\.0+){2})|((255|254|252|248|240|224|192|128|0+)(\.0+){3}))$/ )
    { return $answer; } else { print "Using default: ". $default_mask ."\n"; return $default_mask; }
}

sub prompt_ip {
  my ($query, $default) = @_;
  my $default_ip = lc $default;
  my $answer = lc prompt("$query [$default_ip]: ");

  if ( $answer =~ /^(10|127|169\.254|172\.(1[6-9]|2[0-9]|3[0-1])|192\.168)\./ )
    { return $answer; } else { print "Using default: ". $default_ip ."\n"; return $default_ip; }
}

sub prompt_dns {
  my ($query, $default) = @_;
  my $default_ip = lc $default;
  my $answer = lc prompt("$query [$default_ip]: ");

  if ( $answer =~  qr/^(?!(\.))(\.?(\d{1,3})(?(?{$^N > 255})(*FAIL))){4}$/ )
    { return $answer; } else { print "Using default: ". $default_ip ."\n"; return $default_ip; }
}

sub prompt_hex {
  my ($query, $default) = @_;
  my $default_hex = lc $default;
  my $answer = lc prompt("$query [$default_hex]: ");

  if ( $answer =~  /^(?:[[:xdigit:]]{2})$/ )
    { return $answer; } else { print "Using default: ". $default_hex ."\n"; return $default_hex; }
}

sub prompt_col {
  my ($query, $default) = @_;
  my $default_hex = lc $default;
  my $answer;

  while (1) {
    $answer = lc prompt("$query [$default_hex] - ? for help: ");
    if ( $answer =~  /^\?/ ) { printcols(); }
    if ( $answer =~  /^[0-9a-f]/ ) { last; }
  }

    if ( $answer =~  /^(?:[[:xdigit:]]{1})$/ )
      { return $answer; } else { print "\nUsing default: ". $default_hex ."\n"; return $default_hex; }
}

#####################################################################################
# Taken from Text-Convert-Petscii.pm

sub ascii_to_petscii {
    my ($str_ascii) = @_;
    my $str_petscii = '';
    my $position = 1;
    while ($str_ascii =~ s/^(.)(.*)$/$2/) {
        my $c = ord $1;
        my $code = $c & 0x7f;
        if ($c != $code) {
            #carp sprintf qq{Invalid ASCII code at position %d of converted text string: "0x%02x" (convertible codes include bytes between 0x00 and 0x7f)}, $position, $c;
            $code = 0x20;
        }
        if ($code >= ord 'A' && $code <= ord 'Z') {
            $code += 128;
        } elsif ($code >= ord 'a' && $code <= ord 'z') {
            $code -= 32;
        }
        $str_petscii .= chr $code;
        $position++;
    }
    return $str_petscii;
}


sub petscii_to_ascii {
    my ($code) = @_;
    my $str_ascii = '';
        if ($code >= ord 'A' && $code <= ord 'Z') {
            $code += 32;
        } elsif ($code >= ord 'a' && $code <= ord 'z') {
            $code -= 32;
        } elsif ($code >= 0xc1 && $code <= 0xda) {
            $code -= 128;
        } elsif ($code == 0x7f) {
            $code = 0x3f;
        } 
        $str_ascii .= chr $code;
    return $str_ascii;
}

#####################################################################################
# Texts

sub printcols {

print "\nColor codes are:\n
 0 - Black\t\t 1 - White
 2 - Red\t\t 3 - Cyan
 4 - Purple\t\t 5 - Green
 6 - Blue\t\t 7 - Yellow
 8 - Orange\t\t 9 - Brown
 A - Lt.Red\t\t B - Dark Grey
 C - Grey 2\t\t D - Lt.Green
 E - Lt.Blue\t\t F - Lt.Grey\n\n";
}

sub help {
   die "Syntax: replay-config <infile.bin> [<outfile.bin>]\n\n".

       "Configuration tool to aid setting default values on \'REPLAY\' compatible C64 ROMs.\n".
       "Should ease usage of cart binaries with preferred settings on emulators and Replay compatible hardware.\n\n".

       "Supporting:\n".
       "- Action Replay 5/6/Turbo Action ROM v1/v2\n".
#       "- CyberpunX Replay 3.99+\n".                       TODO
       "- HTTP-Load2\n".
       "- Retro Replay 3.8\n".
       "- SUPERFLUID (as soon as useful options are spotted)\n".
       "- The Final Replay 0.3 - 0.8\n".
       "... and more\n\n";
}
