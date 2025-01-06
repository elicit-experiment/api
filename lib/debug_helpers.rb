class DebugHelpers

  class TreeDumper
    def initialize(root)
      @root = root
      @current_root = root
      @current_level = 0
      @already_dumped = Set.new()
    end

    # DebugHelpers::TreeDumper.new(StudyResult::StudyResult.last).dump
    # bin/rails runner 'require "./lib/debug_helpers"; DebugHelpers::TreeDumper.new(StudyResult::StudyResult.last).dump'
    def dump(current_root = @root)
      puts '  '*@current_level + current_root.inspect

      object_tag ="#{current_root.class.name}:#{current_root.id}"
      return if @already_dumped.include?(object_tag)
      return if @current_level+1 > 5
      @already_dumped << object_tag
      @current_level += 1

      unless current_root.is_a? User#[User].include? current_root.class
        related_associations = current_root.class.reflect_on_all_associations(:belongs_to) +
          current_root.class.reflect_on_all_associations(:has_many) +
          current_root.class.reflect_on_all_associations(:has_one)

        related_associations.each do |association|
          associated_object = current_root.send(association.name)

          unless associated_object.nil?
            puts '  ' * (@current_level - 1) + "- #{association.name}:"
            if associated_object.is_a?(Enumerable)
              associated_object.each do |item|
                dump(item)
              end
            else
              dump(associated_object)
            end
          end
        rescue PG::UndefinedColumn, StandardError
          puts "** Undefined column #{current_root.class.name}##{association.name}"
        end
      end

      @current_level -= 1
      #@already_dumped.delete object_tag

    end

  end
  def self.debug(root)
    puts root.inspect

    puts msg
  end
end