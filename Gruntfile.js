module.exports = function(grunt) {
    ugly_exceptions = [
        "Asteroid", "AsteroidWrapper", "Environment", "Grid", "LandingZone", "Node",
        "Ship", "ShipWrapper", "VAsteroid", "VShip"]

    grunt.initConfig({
        pkg: grunt.file.readJSON('package.json'),

        clean: {
            public: ["public", "assets/rocksinspace*"]
        },

        coffee: {
            options: {
                join: true
            },
            rocksinspace: {
                files: {
                    'coffee/rocksinspace.js': ['coffee/*.coffee']
                }
            }
        },

        uglify: {
            options: {
                mangle: {
                    except: ugly_exceptions
                }
            },
            rocksinspace: {
                files: {'assets/rocksinspace.min.js': ['coffee/rocksinspace.js']}
            }
        },

        htmlmin: {
            options: {
                removeComments: true,
                collapseWhitespace: true
            },
            all: {
                files: {
                    "public/index.html": "index.html"
                }
            }
        },

        cssmin: {
            styles: {
                options: {report: 'min'},
                files: {'public/assets/style.min.css': ['style.css']}
            }
        },

        copy: {
            deploy_assets: {
                files: [
                    {flatten: true, expand: true, src: ['assets/*'], dest: 'public/assets/'}
                ]
            }
        }
    });

    grunt.loadNpmTasks('grunt-contrib-clean');
    grunt.loadNpmTasks('grunt-contrib-coffee');
    grunt.loadNpmTasks('grunt-contrib-uglify');
    grunt.loadNpmTasks('grunt-contrib-htmlmin');
    grunt.loadNpmTasks('grunt-contrib-cssmin');
    grunt.loadNpmTasks('grunt-contrib-copy');

    grunt.registerTask('default', "My default task.", function() {
        grunt.task.run('clean');
        grunt.log.writeln("Generating rocksinspace.min.js using Coffeescript and uglify...");
        grunt.task.run(['coffee', 'uglify']);
        grunt.log.writeln("Generating minified HTML files...");
        grunt.task.run('htmlmin');
        grunt.task.run('cssmin');
        grunt.task.run('copy');
    });
}
