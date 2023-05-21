'use strict';

Object.defineProperty(exports, '__esModule', { value: true });

/** Class for managing external NPM module executables in Nova extensions */
var NPMExecutable_1 = class NPMExecutable
{
	/**
	 * @param {string} binName - The name of the executable found in `node_modules/.bin`
	 */
	constructor( binName )
	{
		this.binName = binName;
		this.PATH = null;
	}

	/**
	 * Install NPM dependencies inside the extension bundle.
	 *
	 * @return {Promise}
	 */
	install()
	{
		let pathPackage = nova.path.join( nova.extension.path, "package.json" );
		if( !nova.fs.access( pathPackage, nova.fs.F_OK ) )
		{
			return Promise.reject( `No such file "${pathPackage}"` );
		}

		return new Promise( (resolve, reject) =>
		{
			let options = {
				args: ["npm", "install", "--only=prod"],
				cwd: nova.extension.path,
			};

			let npm = new Process( "/usr/bin/env", options );
			let errorLines = [];
			npm.onStderr( line => errorLines.push( line.trimRight() ) );
			npm.onDidExit( status =>
			{
				status === 0 ? resolve() : reject( new Error( errorLines.join( "\n" ) ) );
			});

			npm.start();
		})
	}

	/**
	 * Whether the module has been installed inside the extension bundle.
	 *
	 * NOTE: This is unrelated to whether the module has been installed globally
	 * or locally to a given project.
	 *
	 * @return {Boolean}
	 */
	get isInstalled()
	{
		let pathBin = nova.path.join( nova.extension.path, "node_modules/.bin/", this.binName );
		return nova.fs.access( pathBin, nova.fs.F_OK );
	}

	/**
	 * Helper function for instantiating Process object with options needed to
	 * run the module executable using `npx`.
	 *
	 * @param {Object} processOptions
	 * @param {[string]} [processOptions.args]
	 * @param {string} [processOptions.cwd]
	 * @param {Object} [processOptions.env]
	 * @param {string|boolean} [processOptions.shell]
	 * @param {[string]} [processOptions.stdio]
	 * @see {@link https://novadocs.panic.com/api-reference/process}
	 * @return {Promise<Process>}
	 */
	async process( { args=[], cwd, env={}, shell=true, stdio } )
	{
		let options = {
			args: ["npx", this.binName].concat( args ),
			cwd: cwd || nova.extension.path,
			env: env,
			shell: shell,
		};

		if( stdio )
		{
			options.stdio = stdio;
		}

		if( this.PATH === null )
		{
			// Environment.environment added in 1.0b8
			if( nova.environment && nova.environment.PATH )
			{
				this.PATH = nova.environment.PATH;
			}
			else
			{
				this.PATH = await getEnv( "PATH" );
			}
		}

		/* The current workspace path (if any) and the extension's path are
		 * added to the user's $PATH, creating a preferential cascade of
		 * possible executable locations:
		 *
		 *   Current Workspace > Global Installation > Extension Fallback
		 */
		let paths = [];
		if( nova.workspace.path )
		{
			paths.push( nova.workspace.path );
		}
		paths.push( this.PATH );
		paths.push( nova.extension.path );

		options.env.PATH = paths.join( ":" );

		return new Process( "/usr/bin/env", options );
	}
};

/**
 * Helper function for fetching variables from the user's environment
 *
 * @param {string} key
 * @return {Promise<string>}
 */
function getEnv( key )
{
	return new Promise( resolve =>
	{
		let env = new Process( "/usr/bin/env", { shell: true } );

		env.onStdout( line =>
		{
			if( line.indexOf( key ) === 0 )
			{
				resolve( line.trimRight().split( "=" )[1] );
			}
		});

		env.onDidExit( () => resolve() );

		env.start();
	});
}

var npmExecutable = {
	NPMExecutable: NPMExecutable_1
};

const {NPMExecutable} = npmExecutable;

/** Class that provides linting support via external JSONLint executable */
var JSONLint_1 = class JSONLint
{
	constructor()
	{
		this.jsonlint = new NPMExecutable( "jsonlint" );
		if( !this.jsonlint.isInstalled )
		{
			this.jsonlint.install()
				.catch( error =>
				{
					console.error( error );
				});
		}

		this._isNpxInstalled = null;
		this.didNotify = false;

		this.issueCollection = new IssueCollection();
	}

	/**
	 * Returns whether `npx` can be found on $PATH
	 *
	 * @return {Promise<boolean>}
	 */
	get isNpxInstalled()
	{
		if( this._isNpxInstalled )
		{
			return Promise.resolve( true );
		}

		return new Promise( resolve =>
		{
			let env = new Process( "/usr/bin/env", { args: ["which", "npx"], shell: true } );
			env.onDidExit( status =>
			{
				this._isNpxInstalled = status === 0;
				resolve( this._isNpxInstalled );
			});
			env.start();
		});
	}

	/**
	 * Lint a document's contents
	 *
	 * @return {Promise}
	 */
	async lintDocument( textDocument )
	{
		let isNpxInstalled = await this.isNpxInstalled;

		if( !isNpxInstalled && !this.didNotify )
		{
			this.didNotify = true;

			let request = new NotificationRequest( "ashur.JSONLint.npxNotFound" );
			request.title = "NPM Not Found";
			request.body = "JSONLint requires NPM and Node.js. Please download and install the latest version of Node.js, or verify that NPM can be found on $PATH.";
			request.actions = ["OK", "Help"];

			try
			{
				let response = await nova.notifications.add( request );
				if( response.actionIdx === 1 )
				{
					nova.openConfig();
				}
			}
			catch( error )
			{
				console.error( error );
			}
		}

		if( textDocument.syntax !== "json" )
		{
			return;
		}

		let range = new Range( 0, textDocument.length );
		let contents = textDocument.getTextInRange( range );

		return this.lintString( contents, textDocument.uri );
	}

	/**
	 * Write a string to the JSONLint process's STDIN, then parse output and
	 * pass results to reporter.
	 *
	 * @param {String} string
	 * @param {String} fileURI
	 * @see parseOutput
	 * @see report
	 * @return {Promise}
	 */
	async lintString( string, fileURI )
	{
		try
		{
			// Equivalent to running `echo <string> | npx jsonlint -c`
			let process = await this.jsonlint.process( { args: ["-c"] } );

			let output = "";
			process.onStdout( line => output += line.trimRight() );
			process.onStderr( line => output += line.trimRight() );
			process.onDidExit( status =>
			{
				let results = status === 0 ? [] : this.parseOutput( output );

				// We need to report all documents, regardless of whether JSONLint
				// reported any problems. Otherwise, fixing a problem in the
				// document doesn't clear the Issue.
				this.report( results, fileURI );
			});

			process.start();

			let writer = process.stdin.getWriter();
			writer.write( string );
			writer.close();
		}
		catch( error )
		{
			console.error( error );
		}
	}

	/**
	 * Parse a string for JSONLint error output
	 *
	 * @return {[Object]} Array of objects describing results
	 */
	parseOutput( string )
	{
		let results = [];

		// JSONLint only reports one issue at a time, so there's no need to
		// perform a global match.
		let pattern = /line (\d+), col (\d+), found: '([^']+)' - expected: '([^']+)'/;
		let matches = string.match( pattern );

		if( matches )
		{
			results.push({
				line: matches[1],
				column: matches[2],
				found: matches[3],
				expected: matches[4],
			});
		}

		return results;
	}

	/**
	 * @param {String} fileURI
	 */
	removeIssues( fileURI )
	{
		this.issueCollection.remove( fileURI );
	}

	/**
	 * Convert parsed JSONLint output into Nova issues
	 *
	 * @param {[Object]} results
	 * @param {String} fileURI
	 */
	report( results, fileURI )
	{
		let issues = results.map( result =>
		{
			let issue = new Issue();
			issue.message = `Found ${JSON.stringify( result.found )}; Expected ${result.expected}`;
			issue.severity = IssueSeverity.Error;
			issue.line = result.line;
			issue.column = parseInt( result.column ) + 1;

			return issue;
		});

		this.issueCollection.set( fileURI, issues );
	}
};

var jsonlint = {
	JSONLint: JSONLint_1
};

const {JSONLint} = jsonlint;

var activate = async () =>
{
	try
	{
		let jsonlint = new JSONLint();

		/**
		 * Lint all documents as soon as they are opened, and add listeners for
		 * several important lifecycle events.
		 */
		nova.workspace.onDidAddTextEditor( textEditor =>
		{
			jsonlint.lintDocument( textEditor.document );

			textEditor.onDidStopChanging( textEditor =>
			{
				jsonlint.lintDocument( textEditor.document );
			});

			textEditor.document.onDidChangeSyntax( textDocument =>
			{
				jsonlint.lintDocument( textDocument );
			});

			textEditor.onDidDestroy( destroyedTextEditor =>
			{
				// If the backing documents of any other TextEditor instances share
				// the same URI, don't remove the Issues.
				let anotherEditor = nova.workspace.textEditors.find( textEditor =>
				{
					return textEditor.document.uri === destroyedTextEditor.document.uri;
				});

				if( !anotherEditor )
				{
					jsonlint.removeIssues( destroyedTextEditor.document.uri );
				}
			});
		});
	}
	catch( error )
	{
		console.error( error );
	}
};

var main = {
	activate: activate
};

exports.activate = activate;
exports.default = main;
