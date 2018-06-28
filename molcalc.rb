#!/usr/bin/ruby

module Atomlist

  def atomlist_array( atomlist_file = "./atomlist" )
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
          h[ k ] = v.to_i
          k = x
          v = ""
        end
      elsif x =~ /[a-z]/       #   u for Cu, a for Na, etc.
        if    k == ""
          puts "Somethoing ERROR! 2"
          exit
        elsif k != ""
          k << x
          v = "1" if v == ""
          h[ k ] = v.to_i
          k = x
          v = ""
        end
      end
    end
    if    k == ""     and v == ""
      puts "Somethoing ERROR!"
      exit
    elsif k =~ /\D+/  and v == ""
      v = "1" if v == ""
      h[ k ] = v.to_i
    elsif k =~ /\D/  and v =~ /\d/
      h[ k ] = v.to_i
    end
    return h
  end

end

class AtomCalc
  include Atomlist

  def initialize( atomlist_file = "./atomlist" )
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

  def add_atomic_data( atomlist_file )
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
      emm += ( @major_exact_mass[ el ] * num )
    end
    return emm
  end
   
end


if $0 == __FILE__

  mc = AtomCalc.new
  mc.listed_all
  p mc.aw( "H" )
  p mc.ram( "H" )

end
