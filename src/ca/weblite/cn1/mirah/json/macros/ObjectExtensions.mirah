/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

package ca.weblite.cn1.mirah.json.macros
import mirah.lang.ast.*
import org.mirah.util.*
import ca.weblite.mirah.utils.MappableBuilder
import ca.weblite.mirah.utils.DataMapperBuilder
import ca.weblite.mirah.utils.ElemAssignFinder
import ca.weblite.mirah.utils.ArrayUtility
import ca.weblite.mirah.utils.BeanBuilder
import ca.weblite.mirah.utils.MethodFinder
  
/**
 *
 * @author shannah
 */
class ObjectExtensions 
  
  macro def self.mappable(klass:ClassDefinition)
    builder = MappableBuilder.new @mirah, @call
    builder.generateMappableMethods klass
    klass
  end
  
  macro def self.data_mapper(vals:Hash)
    nodes = NodeList.new
    vals.size.times do |i|
      e = vals.get i
      builder = DataMapperBuilder.new(@mirah, @call, TypeName(e.key), TypeName(e.value))
      nodes.add builder.build
    end
    nodes
  end
  
  
  macro def self.bean_class(vals:Hash)
    nodes = NodeList.new
    vals.size.times do |i|
      e = vals.get i
      builder = BeanBuilder.new(@mirah, @call, TypeName(e.key), TypeName(e.value))
      nodes.add builder.build
    end
    nodes
  end
  
  macro def self.to_primitive_array(target:Node, destType:TypeName)
    util = ArrayUtility.new(@mirah, @call)
    util.to_primitive_array(target, destType)
  end
  
  macro def self.to_string_array(target:Node)
    util = ArrayUtility.new(@mirah, @call)
    util.to_string_array(target)
  end
  
  macro def self.unbox_list(target:Node, destType:TypeName)
    quote { unbox_array(java::util::List(`target`).toArray, `destType`) }
  end
  
  macro def self.unbox_array(target:Node, destType:TypeName)
    util = ArrayUtility.new(@mirah, @call)
    util.unbox_array(target, destType)
  end
  
  
  macro def self.cast_array(target, destType:TypeName)
    
    array = gensym
    i = gensym
    out = quote{`gensym`}
    getter = quote { `array`[`i`] }
    getter = Cast.new(@call.position, destType, getter)
    #puts "Before q"
    q = quote { __temp = `destType`[`target`.length]; __temp[`i`] = `getter` }
    #puts "After q"
    #puts AstFormatter.new(q)
    finder = ElemAssignFinder.new
    q.accept finder, nil
    elAssign = finder.results[0]
    elAssign.target = out
    quote do
      begin
        `out` = `destType`[`target`.length]
        while `i`<`array`.length 
            init {  `array` = `target`; `i`=0 }
            pre { `elAssign` }
            post { `i` = `i`+1 }
            
        end
        `out`
      end
        
    end
  end
  
end

