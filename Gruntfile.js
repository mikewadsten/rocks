module.exports = function(grunt) {
    grunt.initConfig({
        pkg: grunt.file.readJSON('package.json'),

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

    grunt.registerTask('default', ['coffee', 'uglify']);
}
