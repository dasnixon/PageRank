class PageRank
  require 'graphviz'

  def self.page_rank(vert_array,edges_array,damping,iterations,rank_vector)
    first = Time.now
    digraph = GraphViz.new(:G, :type => :digraph) #creates a blank digraph to be populated by our arrays
    #creates vertices for digraph
    vert_array.each do |x|
      digraph.add_nodes(x.to_s)
    end
    #pairs up every other 2 indices and places each in an array of one large array i.e. [[1,2],[2,3]]
    edges_array = edges_array.enum_for(:each_slice, 2).to_a
    edges_array.each do |x|
      if !x[1].nil? || !x[0].nil?
        digraph.add_edges(x[0].to_s,x[1].to_s)
      end
    end
    return nil unless digraph.directed? #checks for a directed graph
    min_value = (1.0-damping)/digraph.node_count #gets the lowest value for rank
    pagerank = {}
    digraph.each_node { |_, node|
      pagerank[node] = 1.0/digraph.node_count #sets the rank of each node equal distribution 1/#ofvertices
    }
    iterations.times { |_| #number of time to iterate unless convergence in which it breaks
      conv = 0
      digraph.each_node { |_, node| #iterate through digraph
        rank = min_value
        incidents(node).each { |ref| #get the incidents at a given node and iterate through
          rank += damping * pagerank[ref] / neighbors(ref).size #calculate rank while in incident block
        }
        conv += (pagerank[node] - rank).abs #used to check for convergence
        pagerank[node] = rank #set the new rank for each node
      }
    break if conv < rank_vector #break for convergence
    }
    second = Time.now
    digraph.output( :png => "digraph.png" ) #output the digraph to a .png image
    pagerank.each do |k,v| #print out the node and rank at the particular node
      puts "Node: #{k.id} has a rank of #{v}"
    end
    puts "Amount of time: #{second - first} seconds"
    puts "You can view the digraph in a .png file in your current directory if you would like."
  end

  #gets nodes that have a path from a particular node
  def self.neighbors(node)
    if node.class == String
      @graph.get_node(node).neighbors
    else
      node.neighbors
    end
  end

  #gets nodes that are incident to a particular node
  def self.incidents(node)
    if node.class == String
      @graph.get_node(node).incidents
    else
      node.incidents
    end
  end

  #Validates the string is an integer from user input
  def self.is_int?(string)
    !!(string =~ /^[-+]?[0-9]+$/)
  end

  def self.valid_float?(str)
    !!Float(str) rescue false
  end
end

  vert_array = Array.new
  while vert_array.length == 0
    puts "Build an array for the vertices used in the digraph. Please do not enter duplicates. Type done when finished"
    num = nil
    while (num != "done")
    puts "Please input element by element the array of your desire with a valid integer."
    num = gets.chomp
    if !vert_array.include?(num.to_i)
      if num == "done"
        puts "Final array: #{vert_array}"
        num = "done"
      else
        bool = PageRank.is_int?(num)
          while (bool == false)
            puts "That was an invalid integer. Try again."
            num = gets.chomp
            bool = PageRank.is_int?(num)
          end
          vert_array << num.to_i
          puts "Current array: #{vert_array} with length: #{vert_array.length}"
          num = vert_array.last
        end
      end
    end
  end

  edges_array = Array.new
  while edges_array.length == 0 || edges_array.length % 2 == 1
  puts "Build an array to make the edges in the digraph based on #{vert_array}. It works in pairs of 2 i.e. [1,2,2,3] means node 1 has a path to node 2 and node 2 has a path to node 3"
  num = nil
    while (num != "done")
    puts "Please input element by element the array of your desire, but the array must be even, and must be from the array of vertices you made earlier."
    num = gets.chomp
    if vert_array.include?(num.to_i)
      if num == "done"
        puts "Final array: #{edges_array}"
        num = "done"
      else
        bool = PageRank.is_int?(num)
          while (bool == false)
            puts "That was an invalid integer. Try again."
            num = gets.chomp
            bool = PageRank.is_int?(num)
          end
          edges_array << num.to_i
          puts "Current array: #{edges_array} with length: #{edges_array.length}"
          num = edges_array.last
        end
      end
    end
  end

  #This receives the input for the damping factor
  puts "Input a valid float value between 0 and 1 for the damping factor"
  damp = gets.chomp
  #Validate user input
  bool = PageRank.valid_float?(damp)
  while ((bool == false) || (damp.to_f < 0.0) || (damp.to_f > 1.0))
    puts "That was an invalid floating point number. Try again."
    puts "Input a floating point number between 0 and 1 for the damping factor"
    damp = gets.chomp
    bool = PageRank.valid_float?(damp)
  end
  damping_factor = damp.to_f

  #This receives the input for the number of iterations
  puts "Input a valid ingeter for the number of iterations"
  iter = gets.chomp
  #Validate user input
  bool = PageRank.is_int?(iter)
  while ((bool == false) || (iter.to_i <= 0))
    puts "That was an invalid integer. Try again."
    puts "Input a valid ingeter for the number of iterations"
    iter = gets.chomp
    bool = PageRank.is_int?(iter)
  end
  iterations = iter.to_i

  #This receives the input for the initial ranking vector
  puts "Input a valid ingeter for the initial ranking vector"
  vect = gets.chomp
  #Validate user input
  bool = PageRank.valid_float?(vect)
  while ((bool == false) || (vect.to_f < 0))
    puts "That was an invalid floating point value. Try again."
    puts "Input a valid floating point value for the initial ranking vector"
    vect = gets.chomp
    bool = PageRank.valid_float?(vect)
  end
  ranking_vector = vect.to_f

  puts "Here is your current input:"
  puts "Vertices to be used: #{vert_array}"
  puts "Edges array: #{edges_array}"
  puts "Damping factor: #{damping_factor}"
  puts "Number of iterations: #{iterations}"
  puts "Initial ranking vector: #{ranking_vector}"

  PageRank.page_rank(vert_array,edges_array,damping_factor,iterations,ranking_vector)
