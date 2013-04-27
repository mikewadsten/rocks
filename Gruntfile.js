module.exports = function(grunt) {
    grunt.initConfig({
        pkg: grunt.file.readJSON('package.json'),

        clean: ["public/assets/rocksinspace.*"],

        coffee: {
            joined: {
                options: {join: true},
                files: {
                    'coffee/rocksinspace.js': ['coffee/*.coffee']
                }
            }
        },

        uglify: {
            options: {
                mangle: {
                    except: ['Asteroid', 'AsteroidWrapper', 'Environment', 'Grid', 'Node', 'Ship']
                }
            },
            rocksinspace: {
                files: {'public/assets/rocksinspace.min.js': ['coffee/rocksinspace.js']}
            }
        }
    });

    grunt.loadNpmTasks('grunt-contrib-coffee');
    grunt.loadNpmTasks('grunt-contrib-uglify');
    grunt.loadNpmTasks('grunt-contrib-clean');

    grunt.registerTask('default', "My default task.", function() {
        grunt.log.writeln("Generating rocksinspace.min.js using Coffeescript and uglify...");
        grunt.task.run('clean');
        grunt.task.run(['coffee', 'uglify']);
    });
}
