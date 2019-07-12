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
    assert_equal( 2,  @ca.chop_mol_formula( "CH3COOH" )["O"] )
    assert_equal( 4,  @ca.chop_mol_formula( "CH3COOH" )["H"] )
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

end

