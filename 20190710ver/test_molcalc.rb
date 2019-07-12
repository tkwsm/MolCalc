
require 'test/unit'
require './molcalc.rb'

class ClassAtomlist 
  include Atomlist
end

class TC_ClassAtomlist < Test::Unit::TestCase

  def setup1
    @ca = ClassAtomlist.new
  end

  def test_atomlist_array
  # atomlist_array
    setup1
    assert_equal( 307, @ca.atomlist_array.size )
    assert_equal( true, @ca.atomlist_array.include?(["H",1.0078250319,0.99985]))
    assert_equal( true, @ca.atomlist_array.include?(["As", 74.921594, 1.0]))
    assert_equal( true, @ca.atomlist_array.include?(["Lr", 260.0, 1.0]))
  end

  def test_chop_mol_formula
  # chop_mol_formula( mol_formula )
    setup1
    assert_equal( 2,  @ca.chop_mol_formula( "C2H4O2" )["C"] )
    assert_equal( 4,  @ca.chop_mol_formula( "C2H4O2" )["H"] )
    assert_equal( 2,  @ca.chop_mol_formula( "C2H4O2" )["O"] )
    assert_equal( 16, @ca.chop_mol_formula( "C16H34O" )["C"] )
    assert_equal( 34, @ca.chop_mol_formula( "C16H34O" )["H"] )
    assert_equal( 1,  @ca.chop_mol_formula( "C16H34O" )["O"] )
    assert_equal( 2,  @ca.chop_mol_formula( "C2H6O" )["C"] )
    assert_equal( 6,  @ca.chop_mol_formula( "C2H6O" )["H"] )
    assert_equal( 1,  @ca.chop_mol_formula( "C2H6O" )["O"] )
    assert_equal( 1,  @ca.chop_mol_formula( "CH4" )["C"] )
    assert_equal( 4,  @ca.chop_mol_formula( "CH4" )["H"] )
    assert_equal( 1,  @ca.chop_mol_formula( "NaCl" )["Na"] )
    assert_equal( 1,  @ca.chop_mol_formula( "NaCl" )["Cl"] )
    assert_equal( 1,  @ca.chop_mol_formula( "C6H9Mg" )["Mg"] )
    assert_equal( 6,  @ca.chop_mol_formula( "C6H9Mg" )["C"] )
    assert_equal( 2,  @ca.chop_mol_formula( "H2SeO4" )["H"] )
    assert_equal( 1,  @ca.chop_mol_formula( "H2SeO4" )["Se"] )
    assert_equal( 4,  @ca.chop_mol_formula( "H2SeO4" )["O"] )
    assert_equal(["H", "O", "Se"],  @ca.chop_mol_formula( "H2SeO4" ).keys.sort )
    assert_equal( 26,  @ca.chop_mol_formula( "C26H19Cl2N3O7" )["C"] )
    assert_equal( 19,  @ca.chop_mol_formula( "C26H19Cl2N3O7" )["H"] )
    assert_equal( 2,  @ca.chop_mol_formula( "C26H19Cl2N3O7" )["Cl"] )
    assert_equal( 3,  @ca.chop_mol_formula( "C26H19Cl2N3O7" )["N"] )
    assert_equal( 7,  @ca.chop_mol_formula( "C26H19Cl2N3O7" )["O"] )
    assert_equal(["C","Cl","H","N","O"],  @ca.chop_mol_formula("C26H19Cl2N3O7").keys.sort )
    assert_equal( 1,  @ca.chop_mol_formula( "Fe" )["Fe"] )
    assert_equal( 2,  @ca.chop_mol_formula( "CH3COOH" )["C"] )
  end
end

class TC_AtomCalc < Test::Unit::TestCase

  def setup 
    @obj = AtomCalc.new
  end

#  def test_listed_all
#    assert_equal( "", @obj.listed_all )
#  end

  def test_atomic_wait
  #  atomic_wait( element )
    assert_equal( [[1.0078250319, 2.0141021], [1.0078250319, 2.0141021]], 
                  @obj.atomic_wait( "H" ) )
  end

  def test_relative_atomic_wait
  # relative_atomic_wait( element )
    assert_equal( 1.007975973460215, @obj.relative_atomic_wait( "H" ) )
  end

  def test_exact_masses
  #  exact_masses( element )
    assert_equal( [1.0078250319, 2.0141021], @obj.exact_masses( "H" ) )
  end

  def test_major_exact_mass
  #  major_exact_mass( element ) assert_equal( 1.0078250319, @obj.major_exact_mass( "H" ) )
  end

  def test_add_atomic_data
  # add_atomic_data
  end

end

class TC_MolCalc < Test::Unit::TestCase

  def setup 
    @mc = MolCalc.new
  end

  def test_relative_molecular_mass
  # relative_molecular_mass
#    assert_equal( 16.04301103811886,  @mc.relative_molecular_mass("CH4") )
#    assert_equal( 301.1877,  @mc.relative_molecular_mass("C8H16NO9P").round(4) )
  end

  def test_exact_molecular_mass
  # exact_molecular_mass
    assert_equal( 16.031300127599998, @mc.exact_molecular_mass("CH4") )
    assert_equal( 301.0562691185,  @mc.exact_molecular_mass("C8H16NO9P") )
    assert_equal( 301.0563, @mc.exact_molecular_mass("C8H16NO9P").round(4) )
    assert_equal( 559.0717, @mc.exact_molecular_mass("C15H23N5O14P2").round(4))
    assert_equal( 145.9118, @mc.exact_molecular_mass("H2SeO4").round(4) )
    assert_equal( 555.0600, @mc.exact_molecular_mass("C26H19Cl2N3O7").round(4))
    assert_equal( 55.9349, @mc.exact_molecular_mass("Fe").round(4))
  end

  def test_adduct_H
    assert_equal( 1.0072764319, @mc.adduct_H )
  end

  def test_adduct_mw
    #             [sign, Mass, charge, mult]
    assert_equal(["+",  1.007276, 3.0, 1.0 ], @mc.adduct_mw("[M+3H]3+", 6))
    assert_equal(["+",  8.33459, 3.0, 1.0 ], @mc.adduct_mw("[M+2H+Na]3+", 5))
    assert_equal(["+", 22.9892, 3.0, 1.0], @mc.adduct_mw("[M+3Na]3+", 4))
    assert_equal(["+", 1.007276, 2.0, 1.0], @mc.adduct_mw("[M+2H]2+", 6))
    assert_equal(["+", 9.520551, 2.0, 1.0], @mc.adduct_mw("[M+H+NH4]2+", 6))
    assert_equal(["+", 11.99825, 2.0, 1.0], @mc.adduct_mw("[M+H+Na]2+", 5))
    assert_equal(["+", 19.98522, 2.0, 1.0], @mc.adduct_mw("[M+H+K]2+", 5))
    assert_equal(["+", 22.98922, 2.0, 1.0], @mc.adduct_mw("[M+2Na]2+", 5))
    assert_equal(["+", 22.98922, 1.0, 1.0], @mc.adduct_mw("[M+Na]+", 5))
    assert_equal(["+", 38.963158, 1.0, 1.0], @mc.adduct_mw("[M+K]+", 6))
    assert_equal(["+", 61.0653, 1.0, 1.0], @mc.adduct_mw("[M+IsoProp+H]+", 4))
    assert_equal(["+", 83.0604, 1.0, 1.0], @mc.adduct_mw("[M+2ACN+H]+", 4))
    assert_equal(["+", 22.98922, 1.0, 2.0], @mc.adduct_mw("[2M+Na]+", 5))
    assert_equal(["+", 38.963158, 1.0, 2.0], @mc.adduct_mw("[2M+K]+", 6))
    assert_equal(["+", 64.01577, 1.0, 1.0], @mc.adduct_mw("[M+ACN+Na]+", 6))
    assert_equal(["+", 64.01577, 1.0, 2.0], @mc.adduct_mw("[2M+ACN+Na]+", 6))
    assert_equal(["+", 62.547100, 2.0, 1.0], @mc.adduct_mw("[M+3ACN+2H]2+", 6))
    assert_equal(["+", 21.52055, 2.0, 1.0], @mc.adduct_mw("[M+ACN+2H]2+", 5))
    assert_equal(["+", 76.91904, 1.0, 1.0], @mc.adduct_mw("[M+2K-H]+", 6))
    assert_equal(["+", 33.03349, 1.0, 1.0], @mc.adduct_mw("[M+CH3OH+H]+", 5))
    assert_equal(["+", 42.0338, 1.0, 2.0], @mc.adduct_mw("[2M+ACN+H]+", 4))  #
    assert_equal(["+", 42.0338, 2.0, 1.0], @mc.adduct_mw("[M+2ACN+2H]2+", 4))#
    assert_equal(["+", 42.0338, 1.0, 1.0], @mc.adduct_mw("[M+ACN+H]+", 4))   #
    assert_equal(["+", 18.0338, 1.0, 1.0], @mc.adduct_mw("[M+NH4]+", 4))
    assert_equal(["+", 1.007276, 1.0, 1.0], @mc.adduct_mw("[M+H]+", 6))
##    assert_equal(["+", 15.766190, 3.0, 1.0 ], @mc.adduct_mw("[M+H+2Na]3+", 6))
    assert_equal(["+", 44.97117, 1.0, 1.0], @mc.adduct_mw("[M+2Na-H]+", 5))
    assert_equal(["+", 79.0212, 1.0, 1.0], @mc.adduct_mw("[M+DMSO+H]+", 4))
##    assert_equal(["+", 84.05511, 1.0, 1.0], @mc.adduct_mw("[M+IsoProp+Na+H]+", 6))
    assert_equal(["+", 1.007276, 1.0, 2.0], @mc.adduct_mw("[2M+H]+", 6))
    assert_equal(["+", 18.0338, 1.0, 2.0], @mc.adduct_mw("[2M+NH4]+", 4)) #

    assert_equal(["-", -1.007276, -3.0, 1.0], @mc.adduct_mw("[M-3H]3-", 6)) #
    assert_equal(["-", -1.007276, -2.0, 1.0], @mc.adduct_mw("[M-2H]2-", 6)) #
#    assert_equal(["-", -19.01839, -2.0, 1.0], @mc.adduct_mw("[M-H2O-H]-", 6)) #
    assert_equal(["-", -1.007276, -1.0, 1.0], @mc.adduct_mw("[M-H]-", 6)) #
    assert_equal(["-", 20.97467, -1.0, 1.0], @mc.adduct_mw("[M+Na-2H]-", 5)) #
    assert_equal(["-", 34.969402, -1.0, 1.0], @mc.adduct_mw("[M+Cl]-", 6)) #
    assert_equal(["-", 36.94861, -1.0, 1.0], @mc.adduct_mw("[M+K-2H]-", 5)) #
    assert_equal(["-", 44.99820, -1.0, 1.0], @mc.adduct_mw("[M+FA-H]-", 5)) #
    assert_equal(["-", 59.01385, -1.0, 1.0], @mc.adduct_mw("[M+Hac-H]-", 5)) #
    assert_equal(["-", 78.918885, -1.0, 1.0], @mc.adduct_mw("[M+Br]-", 6)) #
    assert_equal(["-", 112.98559, -1.0, 1.0], @mc.adduct_mw("[M+TFA-H]-", 5)) #
    assert_equal(["-", -1.007276, -1.0, 2.0], @mc.adduct_mw("[2M-H]-", 6)) #
    assert_equal(["-", 44.99820, -1.0, 2.0], @mc.adduct_mw("[2M+FA-H]-", 5)) #
    assert_equal(["-", 59.01385, -1.0, 2.0], @mc.adduct_mw("[2M+Hac-H]-", 5)) #
    assert_equal(["-", -1.007276, -1.0, 3.0], @mc.adduct_mw("[3M-H]-", 6)) #

  end

end

