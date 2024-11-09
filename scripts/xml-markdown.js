var parser = require('xml2js');
var fs = require('fs');

fs.readFile(__dirname + '/projects.xml', function(err, data) {
  parser.parseString(data, function (err, result) {
    var projects = result.rss.channel[0].item;
    projects.forEach(function(p) {

      var name = p['wp:post_name'];
      var date = p['wp:post_date'];
      var d = new Date(date);
      var filename = d.getFullYear() + '-' + ('0' + (d.getMonth()+1)).slice(-2) + '-' + ('0' + d.getDate()).slice(-2) + '-' + name + '.md';
      
      var message = '---\n';
      message += 'title: ' + p['title'] + '\n';
      message += 'date: ' + p['wp:post_date'] + '\n';
      p['wp:postmeta'].forEach(function(m) {
        if (m['wp:meta_key'][0] == 'project_specs_0_spec_info') message += 'project: ' + m['wp:meta_value'] + '\n';
        if (m['wp:meta_key'][0] == 'project_specs_1_spec_info') message += 'status: ' + m['wp:meta_value'] + '\n';
        if (m['wp:meta_key'][0] == 'project_specs_2_spec_info') message += 'location: ' + m['wp:meta_value'] + '\n';
        if (m['wp:meta_key'][0] == 'project_specs_3_spec_info') message += 'size: ' + m['wp:meta_value'] + '\n';
      });
      message += '---\n\n';
      message += p['content:encoded'];

      fs.writeFileSync(__dirname + '/md/' + filename, message);
    });

  });
});
