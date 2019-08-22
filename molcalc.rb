#!/usr/bin/ruby

module Atomlist

  def electron_dalton
    0.0005486
  end

  def atomlist_array( atomlist_file = "./atomlist" )
#  def atomlist_array( atomlist_file = "/home/takeshik/scripts/Tkwsm/MolCalc/atomlist" )
    atomlists = []
    el = ""; aw = 0.0; em = 0.0;
    a = []
    open( atomlist_file ).each do |x|
      next if x =~ /^\#/ 
      a = x.chomp.split("\t") if x =~ /^\S/
      el = a[0]
      aw = a[1].to_f
      ia = a[2].to_f
      atomlists << [el, aw, ia]
    end
    return atomlists
  end

  def chop_mol_formula( mol_formula )
    h = {}
    a = mol_formula.split("")
    # Example: { k => v} : { C => 2, H => 4, O => 2 } for C2H4O2
    k = ""     
    v = ""
    a.each_with_index do |x, i|
      if x =~ /\d/          # 2, 4, 2
        if    v == ""
          v = x
        elsif v != ""
          v << x
        end
      elsif x =~ /[A-Z]/       #   C, H, O
        if    k == ""
          k = x
        elsif k != ""
          v = "1" if v == ""
          if h[ k ] == nil
            h[ k ] = v.to_i 
          else
            h[ k ] += v.to_i 
          end
          k = x
          v = ""
        end
      elsif x =~ /[a-z]/       #   u for Cu, a for Na, etc.
        if    k == ""
          puts "Something ERROR! 2 in molcalc.rb"
          exit
        elsif k != ""
          k << x
        end
      elsif x =~ /[=:]/       #   
        STDERR.puts "Please use molecular formula or composition formula. You can't use '=' and ':' \n"
        next
      end
    end
    if    k == ""     and v == ""
      puts "Something ERROR! 1 in molcalc.rb"
      puts "k is #{k}, v is #{v}"
      exit
    elsif k =~ /\D+/  and v == ""
      v = "1" if v == ""
      if h[ k ] == nil
        h[ k ]  = v.to_i 
      else
        h[ k ] += v.to_i 
      end
    elsif k =~ /\D/  and v =~ /\d/
      if h[ k ] == nil
        h[ k ]  = v.to_i 
      else
        h[ k ] += v.to_i 
      end
    end
    return h
  end

end

class AtomCalc
  include Atomlist

  def initialize( atomlist_file = "./atomlist" )
#  def initialize( atomlist_file = "/home/takeshik/scripts/Tkwsm/MolCalc/atomlist" )
    @atomic_waits = {}
    @relative_atomic_wait = {}
    @exact_masses = {}
    @major_exact_mass = {}
    @elements     = []
    add_atomic_data( atomlist_file )
  end

  def listed_all
    @elements.each do |el|
#      p el
#      p @relative_atomic_wait[el]
#      p @exact_masses[el]
#      print "#{el}\t#{aw}\t#{em}\n"
    end
  end

  def atomic_wait( element )
    @atomic_waits[ element ]
  end
  alias aw atomic_wait

  def relative_atomic_wait( element )
    @relative_atomic_wait[ element ]
  end
  alias raw relative_atomic_wait

  def exact_masses( element )
    @exact_masses[ element ]
  end

  alias em exact_masses

  def major_exact_mass( element )
    @major_exact_mass[ element ]
  end

  alias mem major_exact_mass

  def create_atomic_hash( el, aw, ia )
    @atomic_waits[ el ] = [] if @atomic_waits[ el ] == nil
    @atomic_waits[ el ] << [ aw, ia ]
  end

  def add_atomic_data( atomlist_file = "./atomlist" )
    self.atomlist_array( atomlist_file ).each do |el, aw, ia|
      create_atomic_hash( el, aw, ia )
    end
    @elements = @atomic_waits.keys
    @atomic_waits.each_key do |el|
      tram = 0.0
      @atomic_waits[ el ].each do |aw, em|
        tram += aw.to_f * em.to_f
      end
      @relative_atomic_wait[ el ] = tram
      @atomic_waits[ el ].sort!{|x, y| y[1] <=> x[1] }
      @major_exact_mass[ el ] = @atomic_waits[ el ][0][0]
      atomic_waits_with_abondances = []
      @atomic_waits[ el ].collect!{|x| atomic_waits_with_abondances << x[0] }
      @exact_masses[ el ] = atomic_waits_with_abondances
    end
  end

end

class AdductDat

  def initialize(  charge_sign, adduct_mw, adduct_mw_divided_by_charge, charge, mult )
    @charge_sign = charge_sign
    @adduct_mw   = adduct_mw
    @adduct_mw_divided_by_charge = adduct_mw_divided_by_charge
    @charge      = charge
    @mult        = mult
  end

  attr_reader :charge_sign, :adduct_mw, :adduct_mw_divided_by_charge, :charge, :mult
    
end
   
class MolCalc < AtomCalc

  def relative_molecular_mass( molecular_formula )
    rmm = 0.0
    mf  = molecular_formula
    mfh = chop_mol_formula( mf )
    num = 0
    mfh.each do |el, num|
      rmm += ( @relative_atomic_wait[ el ] * num.to_f )
    end
    return rmm
  end
   
  def exact_molecular_mass( molecular_formula )
    emm = 0.0
    mf  = molecular_formula
    mfh = chop_mol_formula( mf )
    num = 0
    mfh.each do |el, num|
      next if @major_exact_mass[ el ] == nil
      emm += ( @major_exact_mass[ el ] * num )
    end
    return emm
  end

  def adduct_H
     adduct_H_value = 0.0
     adduct_H_value = major_exact_mass( "H" ) - electron_dalton
     return adduct_H_value
  end

  def exact_molecular_mass_without_positive_adduct_H( molecular_formula )
    return_value = 0.0
    return_value = exact_molecular_mass( molecular_formula ) + adduct_H #
    return return_value
  end
   
  def exact_molecular_mass_without_negative_adduct_H( molecular_formula )
    return_value = 0.0
    return_value = exact_molecular_mass( molecular_formula ) - adduct_H #
    return return_value
  end

  def adduct_mw( adduct_formula, digit_accuracy=5 )

    ion_mw_value = 0.0
    ions   = []
    ion    = ""
    mult   = 0.0
    charge = 0.0
    charge_sign = ""
    charge_v = 0.0
    ion_sign    = ""

## parse "Charge_value"
    charge_v = adduct_formula.slice(/](\S+)$/, 1)
    charge_v = charge_v.slice(/(\d+)[+-]$/, 1) if charge_v =~ /\d/
    charge_v = 1.0                             if charge_v !~ /\d/
    charge_v = charge_v.to_f

## parse "Charge_sign"
    charge_sign = "+" if adduct_formula.slice(/](\S+)$/, 1) =~ /\+/
    charge_sign = "-" if adduct_formula.slice(/](\S+)$/, 1) =~ /\-/

## decide "Charge"
    charge = ( "#{charge_sign}" + charge_v.to_s ).to_f

## parse "Mult"- iplication
    adduct_f = adduct_formula.slice(/^\[(\S+)/, 1).slice(/^(\S+)\]/, 1)
    if adduct_f =~ /\d+M/
      mult = adduct_f.slice(/^(\d+)M/, 1).to_f
    else
      mult = 1.0
    end

## parse the formula of each "Ion"
    adduct_f.split("+").each do |tmp_adduct|
      tmp_adduct = "+#{tmp_adduct}" if tmp_adduct !~ /\d?M$/ 
      tmp_adduct.split("-").each do |tmp2_adduct|
        tmp2_adduct = "-#{tmp2_adduct}" if tmp2_adduct !~ /\d?M/ and tmp2_adduct !~ /^\+/
        ions << tmp2_adduct
      end
    end

## calculate the mass of the each "Ion"
    denominator = 1
    ion_mw_value = 0.0
    ion_mws = []

    ions.each do |ion|
# parse ion_sign  #  + or -
      if ion =~ /^\d?M/
        ion_sign = "_"
      elsif ion =~ /^\+/
        ion_sign = "+"
      elsif ion =~ /^\-/
        ion_sign = "-"
      else
        STDERR.puts "error, no sign found in this ion "#{x.ion}"
      end

  # parse mult of ion # ion_mult
      ion_mult = 1.0
    # When paren "(" and ")" was used            # eg. [M+2(COOH)]+
      if ion =~ /^[+-]?\(/ 
        ion_mult = ion.slice(/[+-]?(\d+)\(/, 1).to_f if ion =~ /\d\(/
        ion_mult = 1.0 if ion =~ /^[+-]?\(/
    # When multiply is placed without paren      # eg. [M+3H]+
      elsif ion =~ /^[+-]?\d+[^\(]/ 
        ion_mult = ion.slice(/[+-]?(\d+)[^\(]/, 1).to_f if ion =~ /\d+[^\(]/
    # When both multiply and paren was NOT used  # eg. [M+H]+
      elsif ion =~ /^[+-]?[^\d\(]/ 
        ion_mult = 1.0
      end

  # parse ion formula  # ion
      ion = ion.slice(/[+-](\S+)/, 1)   if ion =~ /[+-]/
      ion = ion.slice(/\d\((\S+)\)/, 1) if ion =~ /\(/ and ion =~ /^[+-]?\d+/
      ion = ion.slice(/\d([^\(]+)/, 1)  if ion !~ /\(/ and ion =~ /^[+-]?\d+/
      ion = ion.slice(/^\((\S+)\)/, 1)  if ion =~ /\(/ and ion !~ /^[+-]?\d+/
      ion = ion.slice(/^([^\(]+)/, 1)   if ion !~ /\(/ and ion !~ /^[+-]?\d+/

  # get ion molecular weight  #  ion_mws
      if ion =~ /M$/
      elsif ion =~ /^H$/
        ion_mws << ion_mult * ("#{ion_sign}" + "#{adduct_H}").to_f
  # electron_dalton
  #  0.0005486
      elsif ion =~ /Na$/ or 
            ion =~ /K$/  or 
            ion =~ /NH4$/
        ion_mws << ("#{ion_sign}"+"#{(ion_mult * ( exact_molecular_mass(ion) - electron_dalton))}").to_f
      elsif ion =~ /IsoProp/
        ion  = "C3H8O"  
        ion_mws << ("#{ion_sign}"+"#{(ion_mult * ( exact_molecular_mass(ion) + electron_dalton))}").to_f
      elsif ion =~ /ACN/
        ion = "C2H3N" 
#        ion_mws << ("#{ion_sign}"+"#{(ion_mult * ( exact_molecular_mass(ion) + electron_dalton))}").to_f
        ion_mws << ("#{ion_sign}"+"#{(ion_mult * exact_molecular_mass(ion) + electron_dalton )}").to_f
      elsif ion =~ /DMSO/
        ion = "C2H6OS" 
        ion_mws << ("#{ion_sign}"+"#{(ion_mult * exact_molecular_mass(ion) + electron_dalton )}").to_f
      elsif ion =~ /H2O/
        ion_mws << ("#{ion_sign}"+"#{(ion_mult * exact_molecular_mass(ion))}").to_f
      elsif ion =~ /Cl$/ or 
            ion =~ /Br$/ 
        ion_mws << ("#{ion_sign}"+"#{(ion_mult * ( exact_molecular_mass(ion) + electron_dalton))}").to_f
      elsif ion =~ /TFA$/
        ion = "CF3COOH" 
        ion_mws << ("#{ion_sign}"+"#{(ion_mult * exact_molecular_mass(ion))}").to_f
      elsif ion =~ /FA$/
        ion = "CH2O2" 
        ion_mws << ("#{ion_sign}"+"#{(ion_mult * exact_molecular_mass(ion))}").to_f
      elsif ion.downcase =~ /hac$/
        ion = "C2H4O2" 
        ion_mws << ("#{ion_sign}"+"#{(ion_mult * exact_molecular_mass(ion))}").to_f
      else
        ion_sign = ion.slice(/([+-])/, 1)
        ion_mws << ("#{ion_sign}"+"#{(ion_mult * exact_molecular_mass(ion))}").to_f
      end
    end

    adduct_mw = 0.0
    ion_mws.each{ |sub_adduct_mw| adduct_mw += sub_adduct_mw }
##    adduct_mw = adduct_mw - ( charge * electron_dalton )
    adduct_mw_divided_by_charge = (adduct_mw/charge.abs).round(digit_accuracy)
    AdductDat.new( charge_sign, adduct_mw, adduct_mw_divided_by_charge, charge, mult )
  end

end


if $0 == __FILE__

# USAGE
# ruby molcalc.rb CH3COOH

#  mc = AtomCalc.new
#  mc.listed_all
#  p mc.aw( "H" )
#  p mc.raw( "H" )

  mc = MolCalc.new
# mc = MolCalc.new( ARGV.shift )
#  mf  = ARGV.shift
#  print mc.exact_molecular_mass( mf ).round(4), "\n"
#  print mc.exact_molecular_mass( mf ), "\n"
p  mc.adduct_mw( "[M+C2H7N+H]+" )
#  print mc.exact_molecular_mass("C2H7N"), "\n"
#  print mc.adduct_H, "\n"
#  adduct_formula = "[M+NH4]+"
#  mc.adduct_mw( adduct_formula )
#  adduct_formula = "[M+C2H7N+H]+"
#  mc.adduct_mw( adduct_formula )
#  adduct_formula = "[M-H2O-H]-"
#  mc.adduct_mw( adduct_formula )
#  adduct_formula = "[M+5(NaCOOH)+Na-2H]-"
#  mc.adduct_mw( adduct_formula )
  adduct_formula = "[M+3H]3+"
p  mc.adduct_mw( adduct_formula )
# [M+C2H7N+H]
  
end

