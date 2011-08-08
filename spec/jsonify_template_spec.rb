describe Tilt::JsonifyTemplate do
  it 'should be associated with .jsonify files' do
    template = Tilt.new('spec/hello_world.jsonify')
    template.should be_a_kind_of(Tilt::JsonifyTemplate)
  end
  it 'should render the template' do
    template = Tilt.new('spec/hello_world.jsonify')
    template.render.should == "{\"hello\":\"world\"}"
  end
end