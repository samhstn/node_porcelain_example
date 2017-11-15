const routes = [
  {
    method: 'get',
    path: '/',
    handler: (request, reply) => setTimeout(() => reply.view('index', { message: 'Hello World' }), 1000)
  },
  {
    method: 'get',
    path: '/resource/{param*}',
    handler: { directory: { path: 'public' } }
  }
]

module.exports = routes;
